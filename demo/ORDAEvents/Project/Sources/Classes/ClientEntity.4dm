
// ============================================
// CLASS 1: ClientEntity
// File: Project/Sources/Classes/ClientEntity.4dm
// ============================================

Class extends Entity

// Event: When Name attribute is modified in memory
Function event touched Name($event : Object)
	// Automatically convert name to UPPERCASE
	This:C1470.Name:=Uppercase:C13(This:C1470.Name)