extends Node3D

class_name LegoPiece

func findSnapTransform() -> Transform3D :
	if "stickyFemaleSurface" in self :
		var transformFromStickyFemale = self.stickyFemaleSurface.findSnapTransform()
		if transformFromStickyFemale.origin.length() > 0:
			return transformFromStickyFemale
	if "stickyMaleSurface" in self :
		var transformFromStickyMale = self.stickyMaleSurface.findSnapTransform()
		if transformFromStickyMale.origin.length() > 0:
			return transformFromStickyMale
	if "insertableFemaleSurface" in self :
		var transformFromInsertableFemale = self.insertableFemaleSurface.findSnapTransform()
		if transformFromInsertableFemale.origin.length() > 0:
			return transformFromInsertableFemale
	return Transform3D()

func snap(newTransform: Transform3D) -> void:
	self.global_transform = newTransform

	var targetPiece = null

	# vérifie les pins côté female
	var snappableFemalePins
	if "stickyFemaleSurface" in self :
		snappableFemalePins = self.stickyFemaleSurface.findSnappablePins()
		for pin in snappableFemalePins.StickyMalePins :
			(pin as StickyMalePin).setUnAvailable()
		for pin in snappableFemalePins.StickyFemalePins :
			(pin as StickyFemalePin).setUnAvailable()

	# vérifie les pins côté male
	var snappableMalePins
	if "stickyMaleSurface" in self :
		snappableMalePins = self.stickyMaleSurface.findSnappablePins()
		for pin in snappableMalePins.StickyMalePins :
			(pin as StickyMalePin).setUnAvailable()
		for pin in snappableMalePins.StickyFemalePins :
			(pin as StickyFemalePin).setUnAvailable()

	# récupère les segments connectés après le snap
	var matches
	if "insertableFemaleSurface" in self :
		matches = self.insertableFemaleSurface.findSnappableSegments()
		for segment in matches.males :
			(segment as InsertableMaleSegment).setUnAvailable()
		for segment in matches.females :
			(segment as InsertableFemaleSegment).setUnAvailable()

	# gère le changement de parents des pièces

	if !targetPiece && snappableFemalePins && snappableFemalePins.StickyMalePins.size() > 0:
		targetPiece = snappableFemalePins.StickyMalePins[0].get_parent().get_parent()
		self.reparent(targetPiece)

	if !targetPiece && matches && matches.males.size() > 0:
		targetPiece = matches.males[0].get_parent()
		self.reparent(targetPiece)

	if !targetPiece && snappableMalePins.StickyFemalePins.size() > 0:
		targetPiece = snappableMalePins.StickyFemalePins[0].get_parent().get_parent()
		self.reparent(targetPiece)
