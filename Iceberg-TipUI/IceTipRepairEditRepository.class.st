"
I will open the edit repository window.

I'm active when: 
	- src subdirectory is not found.
"
Class {
	#name : #IceTipRepairEditRepository,
	#superclass : #IceTipRepairAction,
	#category : #'Iceberg-TipUI-Commands'
}

{ #category : #accessing }
IceTipRepairEditRepository class >> help [
	^ 'You can edit the repository to inform another subdirectory name. 
Once the new subdirectory is updated, the packages in the repository are available.
This action does not affect the changes in the disk working copy nor in the image.

This happens because the source code directory has been moved or renamed.
'
]

{ #category : #accessing }
IceTipRepairEditRepository class >> icon [
	^ self iconNamed: #edit
]

{ #category : #testing }
IceTipRepairEditRepository class >> isAvailableFor: aRepository [

	^ aRepository isMissing not and: [aRepository isCodeMissing]
]

{ #category : #accessing }
IceTipRepairEditRepository class >> order [
	^ 17
]

{ #category : #accessing }
IceTipRepairEditRepository class >> title [
	^ 'Edit the repository to select the correct code subdirectory'
]

{ #category : #executing }
IceTipRepairEditRepository >> basicExecute [

	(IceTipEditProjectDialogPresenter
		newApplication: context application
		model: self repositoryModel entity project)
		openDialog
]
