# UI

- click sur bouton "ajouter"
- ouvre une "modal" d'ajout
- Modal d'ajout :
	- Sélection du type : "beam" / "brick" / "axle" / "klip" / "special"
		ou un certain nombre de presets
	- Paramètres propres au type : width, depth, length, technic pin
	- choix de la couleur
	- Prévisualisation de la brick
	- bouton "ajouter à la scène"

# Gears & Engine

Engine :
- Ajouter un stockage de l'axe entraîné

Axes :
- Ajouter un stockage de tous les gears entrainés
- mettre à jour le stockage lors des snap() et pickup()

Gears :
- Ajouter un moment d'inertie (ralentit les rpm et baisse le couple)
- ???? Détecter les gears entrainés ????

roue :
- Alimentée par un axe
- RPM final calculé selon la suite de moments et de rapports
