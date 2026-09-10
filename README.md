# Jeremy Janin Blog

https://jeremyjanin.com
This is automatically synced with Netlify

## Page Moments

`content/moments/` est synchronisé chaque jour à 6h UTC depuis un album partagé Lightroom
par `.github/workflows/moments.yaml` → `bin/download-lr.rb` (secrets `LIGHTROOM_SPACE_ID` /
`LIGHTROOM_ALBUM_ID`). Le script compare l'album au manifest `content/moments/.manifest.json`,
ne télécharge que les nouvelles photos, renomme si l'ordre change et supprime les retirées.
Pas de diff = pas de commit = pas de build Netlify.

Relancer à la main : onglet Actions → workflow « Moments » → *Run workflow*.

Si Adobe casse quelque chose, le script sort en erreur sans rien supprimer. Regarder d'abord
le dernier commit de Grégory Mignard sur `bin/download-lr.rb`
(https://github.com/gmignard/my_hugo_blog) : ce fichier est un portage du sien, son correctif
se reporte presque tel quel.

# License

The following directories and their contents are Copyright Jeremy Janin.
Less Theme created by Yannick Schutz (https://github.com/ys) & Grégory Mignard (https://github.com/gmignard/)

You may not reuse anything therein without my permission:
.content/

All other directories and files are MIT Licensed.
