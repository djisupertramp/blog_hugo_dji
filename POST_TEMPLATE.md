---
title: ""
seotitle: ""
date: ""
slug: ""
subtitle: ""
categories:
  -
tags: [""]
description: ""
draft: false

# Métadonnées optionnelles (encart hero)
# Décommenter celles dont vous avez besoin :
# location: ""
# camera: ""
# film: ""
# bike: ""

resources:
  - src: "cover.jpg"
    name: "cover"
  - src: "*.jpg"
---

Texte d'introduction ici.

---

<!-- ═══════════════════════════════════════════════════════ -->
<!--               RÉFÉRENCE SHORTCODES & MISE EN PAGE     -->
<!--               Supprimer cette section avant publication -->
<!-- ═══════════════════════════════════════════════════════ -->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    STRUCTURE DU DOSSIER                 -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
content/posts/mon-article/
├── index.md
├── cover.jpg
└── images/
    ├── 01.jpg
    ├── 02.jpg
    └── ...
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    FRONTMATTER YAML                     -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
CHAMPS REQUIS :
  title         Titre affiché dans l'article
  seotitle      Titre pour Google (peut différer du title)
  date          Format "YYYY-MM-DD"
  slug          URL — ex: mon-article → /mon-article
  categories    Une parmi : note, aventures, materiel, guides, creations
  description   Description meta SEO + partages sociaux
  resources     Cover + images du dossier

CHAMPS OPTIONNELS :
  subtitle      Sous-titre affiché sous le titre dans le hero
  tags          Tags libres — format: ["tag1", "tag2"]
  draft         true = brouillon non publié (false par défaut)
  location      Lieu — affiché dans l'encart métadonnées du hero
  camera        Appareil photo utilisé
  film          Pellicule utilisée
  bike          Vélo utilisé
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    TITRES                               -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Ne pas utiliser # (H1) dans le contenu — réservé au title du frontmatter.
Commencer les sections par ## (H2).

## Titre de section              → H2 — Oswald light 1.6rem
### Sous-titre                   → H3 — Oswald light 1.6rem
#### Petit titre                 → H4 — Oswald light 1.4rem
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    TEXTE                                -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
**gras**
*italique*
***gras italique***
[texte du lien](https://url.com)

> Citation — bordure gauche accent, italique, serif

- Liste à puces
- Deuxième élément

1. Liste numérotée
2. Deuxième élément
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    SÉPARATEUR                           -->
<!-- ─────────────────────────────────────────────────────── -->

<!-- Trois tirets produisent un séparateur visuel • • •

---

-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    PHOTO SIMPLE                         -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Image standard (largeur colonne) :
{{< photo src="images/01.jpg" alt="Description" >}}

Image large (déborde de la colonne) :
{{< photo src="images/01.jpg" alt="Description" wide="true" >}}

Image avec légende :
{{< photo src="images/01.jpg" alt="Description" title="*Ma légende en italique*" >}}

Paramètres :
  src     (requis)  Chemin relatif au dossier de l'article
  alt     (reco)    Texte alternatif accessibilité + SEO
  wide    (opt)     "true" pour déborder de la colonne
  title   (opt)     Légende sous l'image (supporte markdown)
  class   (opt)     Classe CSS additionnelle
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    GALERIE / PHOTOSET                   -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
2 photos côte à côte (toujours 2 colonnes, même sur mobile) :
{{< photoset always="2" >}}
{{< photo src="images/01.jpg" alt="alt text" >}}
{{< photo src="images/02.jpg" alt="alt text" >}}
{{</ photoset >}}

2 colonnes (repasse en 1 colonne sur mobile) :
{{< photoset max="2" >}}
{{< photo src="images/01.jpg" alt="alt text" >}}
{{< photo src="images/02.jpg" alt="alt text" >}}
{{</ photoset >}}

3 colonnes (défaut, sans paramètre) :
{{< photoset >}}
{{< photo src="images/01.jpg" alt="" >}}
{{< photo src="images/02.jpg" alt="" >}}
{{< photo src="images/03.jpg" alt="" >}}
{{</ photoset >}}

4 colonnes :
{{< photoset max="4" >}}
{{< photo src="images/01.jpg" alt="" >}}
{{< photo src="images/02.jpg" alt="" >}}
{{< photo src="images/03.jpg" alt="" >}}
{{< photo src="images/04.jpg" alt="" >}}
{{</ photoset >}}

Paramètres :
  always  (opt)  "2" = force 2 colonnes même sur mobile
  max     (opt)  "2" ou "4" = nombre de colonnes (1 col sur mobile)
  défaut         Sans paramètre = grille 3 colonnes
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    GALLERY (ALTERNATIVE)                -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Galerie 2 colonnes :
{{< gallery cols="2" >}}
{{< photo src="images/01.jpg" alt="Description" >}}
{{< photo src="images/02.jpg" alt="Description" >}}
{{< /gallery >}}

Galerie 3 colonnes :
{{< gallery cols="3" >}}
{{< photo src="images/01.jpg" alt="" >}}
{{< photo src="images/02.jpg" alt="" >}}
{{< photo src="images/03.jpg" alt="" >}}
{{< /gallery >}}

Paramètres :
  cols  (opt)  "2" ou "3" (défaut: 2). Passe en 1 col sur mobile.
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    PLEINE LARGEUR + PARALLAXE           -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Image pleine largeur (100% viewport) :
{{< fullwidth src="images/paysage.jpg" >}}

Avec légende :
{{< fullwidth src="images/paysage.jpg" caption="Ma légende" >}}

Avec effet parallaxe (image fixe au scroll, hauteur 70vh) :
{{< fullwidth src="images/paysage.jpg" parallax="true" >}}

Parallaxe + légende :
{{< fullwidth src="images/paysage.jpg" parallax="true" caption="Légende" alt="Description" >}}

Paramètres :
  src       (requis)  Chemin de l'image
  caption   (opt)     Légende centrée sous l'image
  parallax  (opt)     "true" = effet parallaxe (désactivé auto sur mobile)
  alt       (opt)     Texte alternatif
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    LÉGENDE NARRATIVE                    -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Bloc de texte stylisé — italique, gris, idéal après une photo :
{{< caption >}}Une belle journée pour rouler sur les chemins.{{< /caption >}}

Supporte le markdown à l'intérieur.
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    VIDÉO YOUTUBE                        -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Vidéo standard (ratio 16:9) :
{{< video id="dQw4w9WgXcQ" >}}

Avec autoplay :
{{< video id="dQw4w9WgXcQ" autoplay="true" >}}

Embed Hugo natifs (utilisés dans certains anciens articles) :
{{< youtube dQw4w9WgXcQ >}}
{{< vimeo 123456789 >}}

Paramètres video :
  id        (requis)  ID YouTube (partie après v= dans l'URL)
  autoplay  (opt)     "true" pour lecture automatique
  title     (opt)     Titre accessibilité (défaut: "YouTube Video")
  class     (opt)     Classe CSS additionnelle
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    TEXTE + IMAGE CÔTE À CÔTE            -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
Texte à gauche, image à droite :
{{< columns src="photo.jpg" before >}}
Votre texte ici en **Markdown**.

Plusieurs paragraphes possibles.
{{< /columns >}}

Image à gauche, texte à droite :
{{< columns src="photo.jpg" after >}}
Votre texte ici.
{{< /columns >}}

Paramètres :
  src     (requis)  Nom du fichier image (dans les ressources de la page)
  before  (flag)    Le texte s'affiche AVANT (à gauche de) l'image
  after   (flag)    Le texte s'affiche APRÈS (à droite de) l'image
-->


<!-- ─────────────────────────────────────────────────────── -->
<!--                    STRUCTURE RECOMMANDÉE                 -->
<!-- ─────────────────────────────────────────────────────── -->

<!--
1. Introduction (1-2 paragraphes) sans image avant
2. Photo ou galerie d'intro
3. Corps de l'article avec ## pour chaque section
4. Alterner texte et photos pour le rythme
5. Utiliser {{< caption >}} pour les légendes narratives
6. {{< fullwidth parallax="true" >}} pour marquer une rupture visuelle
7. Conclure avec une réflexion ou une ouverture
-->
