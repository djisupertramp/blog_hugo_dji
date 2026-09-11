require "net/http"
require "json"
require "date"
require "uri"

MANIFEST_PATH = "content/moments/.manifest.json"
CONTENT_DIR   = "content/moments"

# Fichiers du bundle qui ne sont pas des photos d'album : jamais supprimés.
PROTECTED_FILES = [".manifest.json", "index.md"].freeze
# Une photo d'album et rien d'autre : 000.jpg, 001.jpg, ...
ALBUM_FILE = /\A\d{3}\.jpg\z/

# Chemins JSON ou Adobe peut exposer la date de prise de vue, par ordre de
# preference. On detecte celui qui repond et on s'y tient pour tout l'album ;
# si aucun ne repond, on garde l'ordre de la liste renvoyee par l'API.
CAPTURE_DATE_PATHS = [
  %w[asset payload captureDate],
  %w[asset payload xmp exif DateTimeOriginal],
  %w[asset payload importSource importTimestamp],
  %w[asset payload develop croppedCaptureDate],
  %w[asset created],
].freeze

# Garde-fou anti-page vide : en dessous de ce ratio du manifest existant,
# on considere que l'API ment et on ne touche a rien.
MIN_RATIO = 0.7

class Downloader
  def initialize(space_id, album_id)
    @space_id = space_id
    @album_id = album_id
    @stats = { present: 0, downloaded: 0, renamed: 0, failed: 0, deleted: 0, skipped: 0 }
  end

  def run
    old_manifest, manifest_exists = load_manifest

    assets = fetch_assets
    guard_album_size!(assets, old_manifest) if manifest_exists
    assets = sort_by_capture_date(assets)

    new_manifest = {}
    assets.each_with_index do |a, i|
      new_manifest[index_to_filename(i)] = a["asset"]["id"]
    end

    if manifest_exists
      # current_by_id: asset_id => filename, only for files that exist on disk
      current_by_id = {}
      old_manifest.each do |filename, asset_id|
        current_by_id[asset_id] = filename if File.exist?(File.join(CONTENT_DIR, filename))
      end
      run_sync(assets, new_manifest, current_by_id)
    else
      puts "⚠️ Pas de manifest existant, mode migration : téléchargement complet"
      run_migration(assets, new_manifest)
    end

    File.write(MANIFEST_PATH, JSON.pretty_generate(new_manifest))
    puts "📝 Manifest mis à jour (#{new_manifest.size} assets)"
    puts "\nBilan : #{@stats[:present]} présentes, #{@stats[:downloaded]} téléchargées, #{@stats[:renamed]} renommées, #{@stats[:skipped]} ignorées, #{@stats[:failed]} échecs, #{@stats[:deleted]} supprimées"
  end

  private

  # Recupere la liste de l'album et refuse de continuer si la reponse est
  # suspecte. Aucun fichier n'est touche avant que ces garde-fous soient passes.
  def fetch_assets
    resp = Net::HTTP.get(URI(asset_url))
    resp = resp.sub("while (1) {}", "")

    begin
      payload = JSON.parse(resp)
    rescue JSON::ParserError => e
      abort_without_changes("réponse API illisible, JSON invalide (#{e.message})")
    end

    assets = payload["resources"]
    if assets.nil? || !assets.is_a?(Array) || assets.empty?
      abort_without_changes("l'API ne renvoie aucun asset (« resources » absent ou vide)")
    end

    usable = assets.reject do |a|
      next false if rendition_href(a)
      puts "⏭️ Asset #{a.dig('asset', 'id') || '?'} ignoré : pas de rendition 2048"
      @stats[:skipped] += 1
      true
    end

    abort_without_changes("aucun asset ne possède de rendition 2048") if usable.empty?

    puts "📋 #{usable.size} assets exploitables dans l'album"
    usable
  end

  # Un album qui fond d'un coup est presque toujours une panne cote Adobe,
  # pas une suppression volontaire : on prefere echouer bruyamment.
  def guard_album_size!(assets, old_manifest)
    return if old_manifest.empty?

    minimum = (old_manifest.size * MIN_RATIO).ceil
    return if assets.size >= minimum

    abort_without_changes(
      "l'album ne compte que #{assets.size} photos contre #{old_manifest.size} au manifest " \
      "(seuil : #{minimum}, soit #{(MIN_RATIO * 100).round} %)"
    )
  end

  def abort_without_changes(reason)
    warn "❌ Abandon : #{reason}"
    warn "   Aucun fichier n'a été modifié dans #{CONTENT_DIR}/."
    exit 1
  end

  # L'ordre renvoye par l'API est celui d'ajout a l'album, pas celui des prises
  # de vue : l'import initial ayant ete fait de la plus recente a la plus
  # ancienne, il est a l'envers. On renumerote donc par date reelle, du plus
  # ancien au plus recent, pour que le tri "desc" du layout affiche bien les
  # photos recentes en haut.
  def sort_by_capture_date(assets)
    path = CAPTURE_DATE_PATHS.find { |p| assets.any? { |a| date_string(a.dig(*p)) } }

    if path.nil?
      puts "\u26A0\uFE0F Aucune date de prise de vue dans la reponse API : ordre de la liste conserve"
      log_payload_shape(assets.first)
      return assets
    end

    dated = assets.each_with_index.map { |a, i| [date_string(a.dig(*path)), i, a] }
    found = dated.count { |d, _, _| d }
    puts "\u{1F5D3}\uFE0F Tri par « #{path.join('.')} » — #{found}/#{assets.size} assets dates"
    puts "\u26A0\uFE0F #{assets.size - found} sans date : laisses en fin, dans l'ordre de l'API" if found < assets.size

    # Les non dates partent a la fin ; l'index d'origine sert de cle de repli
    # pour que le tri soit stable, donc la numerotation reproductible.
    dated.sort_by { |d, i, _| [d ? 0 : 1, d.to_s, i] }.map(&:last)
  end

  # Les formats rencontres (ISO 8601 et "2024:05:12 10:30:00" d'EXIF) se
  # trient correctement en comparaison lexicographique, sans parsing.
  def date_string(value)
    return nil unless value.is_a?(String)
    stripped = value.strip
    stripped.empty? ? nil : stripped
  end

  # Diagnostic : l'API Adobe n'est pas joignable depuis l'environnement de
  # developpement, ce log permet d'identifier le bon champ depuis un run reel.
  def log_payload_shape(asset)
    return unless asset.is_a?(Hash)
    puts "\u{1F50D} Cles de l'asset : #{asset.keys.inspect}"
    payload = asset.dig("asset", "payload")
    puts "\u{1F50D} Cles de asset.payload : #{payload.keys.inspect}" if payload.is_a?(Hash)
  end

  def run_sync(assets, new_manifest, current_by_id)
    # Collect renames needed (old_name != expected_name for the same asset_id)
    renames = []
    assets.each_with_index do |a, i|
      asset_id      = a["asset"]["id"]
      expected_name = index_to_filename(i)
      current_name  = current_by_id[asset_id]
      renames << { asset_id: asset_id, old: current_name, new: expected_name } if current_name && current_name != expected_name
    end

    # Phase 1a: move to temp names to avoid collision chains
    temp_names = {}
    renames.each do |r|
      tmp = "tmp_#{r[:asset_id]}.jpg"
      File.rename(File.join(CONTENT_DIR, r[:old]), File.join(CONTENT_DIR, tmp))
      temp_names[r[:asset_id]] = tmp
    end

    # Phase 1b: move from temp to final names
    renames.each do |r|
      File.rename(File.join(CONTENT_DIR, temp_names[r[:asset_id]]), File.join(CONTENT_DIR, r[:new]))
      puts "🔀 #{r[:old]} → #{r[:new]}"
      @stats[:renamed] += 1
      current_by_id[r[:asset_id]] = r[:new]
    end

    # Phase 2: download missing assets
    assets.each_with_index do |a, i|
      expected_name = index_to_filename(i)
      asset_id      = a["asset"]["id"]

      if current_by_id[asset_id] == expected_name
        puts "⏭️ #{expected_name} déjà à jour, skip"
        @stats[:present] += 1
        next
      end

      puts "⬇️ Téléchargement de #{expected_name}"
      data = download_with_retry(rendition_url(a), expected_name)
      if data
        File.open(File.join(CONTENT_DIR, expected_name), "wb") { |f| f.write(data) }
        @stats[:downloaded] += 1
      else
        puts "⚠️ Échec téléchargement #{expected_name} (403/timeout), fichier local conservé si existant"
        @stats[:failed] += 1
      end
    end

    delete_obsolete(new_manifest, "retirée de l'album")
  end

  def run_migration(assets, new_manifest)
    inventory = Dir.glob("#{CONTENT_DIR}/*").map { |f| File.basename(f) }.sort
    puts "📂 Inventaire avant migration (#{inventory.size}) : #{inventory.join(', ')}"
    puts "🔒 Fichiers protégés : #{PROTECTED_FILES.join(', ')} (et tout ce qui n'est pas NNN.jpg)"

    assets.each_with_index do |a, i|
      filename = index_to_filename(i)
      puts "⬇️ Téléchargement de #{filename} (migration)"
      data = download_with_retry(rendition_url(a), filename)
      if data
        File.open(File.join(CONTENT_DIR, filename), "wb") { |f| f.write(data) }
        @stats[:downloaded] += 1
      else
        puts "⚠️ Échec téléchargement #{filename} (403/timeout), fichier local conservé si existant"
        @stats[:failed] += 1
      end
    end

    delete_obsolete(new_manifest, "hors index API")
  end

  def delete_obsolete(new_manifest, reason)
    Dir.glob("#{CONTENT_DIR}/*").each do |local_file|
      basename = File.basename(local_file)
      next if PROTECTED_FILES.include?(basename)
      next unless basename.match?(ALBUM_FILE)
      next if new_manifest.key?(basename)
      File.delete(local_file)
      puts "🗑️ #{basename} supprimée (#{reason})"
      @stats[:deleted] += 1
    end
  end

  def load_manifest
    return [{}, false] unless File.exist?(MANIFEST_PATH)
    [JSON.parse(File.read(MANIFEST_PATH)), true]
  rescue JSON::ParserError
    [{}, false]
  end

  def index_to_filename(i)
    "#{i.to_s.rjust(3, '0')}.jpg"
  end

  def rendition_href(asset)
    asset.dig("asset", "links", "/rels/rendition_type/2048", "href")
  end

  def rendition_url(asset)
    "https://lightroom.adobe.com/v2/spaces/#{@space_id}/#{rendition_href(asset)}"
  end

  def download_with_retry(url, label, max_retries: 2)
    attempts = 0
    loop do
      attempts += 1
      data, code = fetch_following_redirects(url)
      puts "🔍 [DEBUG] #{label} → #{url} → HTTP #{code}"

      return data if code == 200 && data && !data.empty?

      if attempts < max_retries
        puts "🔄 Retry #{attempts}/#{max_retries - 1} dans 2s..."
        sleep 2
      else
        return nil
      end
    end
  end

  def fetch_following_redirects(url, redirect_limit: 5)
    raise "Trop de redirections" if redirect_limit == 0

    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = (uri.scheme == "https")
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    response = http.request(request)

    case response
    when Net::HTTPRedirection
      fetch_following_redirects(response["location"], redirect_limit: redirect_limit - 1)
    when Net::HTTPSuccess
      [response.body, response.code.to_i]
    else
      [nil, response.code.to_i]
    end
  end

  def asset_url
    "https://lightroom.adobe.com/v2/spaces/#{@space_id}/albums/#{@album_id}/assets?embed=asset%3Buser&order_after=-&exclude=incomplete&subtype=image%3Bvideo%3Blayout_segment&limit=1000"
  end
end

Downloader.new(ARGV[0], ARGV[1]).run
