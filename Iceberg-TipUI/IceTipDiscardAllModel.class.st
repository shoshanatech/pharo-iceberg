Class {
	#name : #IceTipDiscardAllModel,
	#superclass : #IceTipModel,
	#instVars : [
		'workingCopy',
		'diffModel',
		'repository'
	],
	#category : #'Iceberg-TipUI-Model'
}

{ #category : #operations }
IceTipDiscardAllModel >> calculateDiff [
	
	^ workingCopy referenceCommit diffTo: workingCopy
]

{ #category : #operations }
IceTipDiscardAllModel >> diff [

	^ diffModel ifNil: [ 
		  | diff |
		  UIManager default
			  informUser: 'Calculating diff'
			  during: [ diff := self calculateDiff ].
		  diffModel := IceTipCommitDiffModel
			               repositoryModel: self repositoryModel
			               on: diff ]
]

{ #category : #operations }
IceTipDiscardAllModel >> discardAll [
	
	workingCopy discardChanges
]

{ #category : #operations }
IceTipDiscardAllModel >> newDiscardAction [
	<noCache>

	^ IceTipStandardAction new 
		repository: self repository;
		message: ('Discarding changes in the image');
		onSuccessRepositoryModified;
		action: [ self discardAll ];
		yourself
]

{ #category : #accessing }
IceTipDiscardAllModel >> repository [
	^ repository
]

{ #category : #accessing }
IceTipDiscardAllModel >> repository: anIceTipCachedModel [ 
	
	repository := anIceTipCachedModel
]

{ #category : #accessing }
IceTipDiscardAllModel >> workingCopy [

	^ workingCopy
]

{ #category : #accessing }
IceTipDiscardAllModel >> workingCopy: anObject [

	workingCopy := anObject
]
