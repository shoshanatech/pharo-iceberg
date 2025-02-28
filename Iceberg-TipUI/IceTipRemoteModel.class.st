"
I'm a model for IceRemote entries.
"
Class {
	#name : #IceTipRemoteModel,
	#superclass : #IceTipEntityModel,
	#traits : 'TWithBranchModel',
	#classTraits : 'TWithBranchModel classTrait',
	#category : #'Iceberg-TipUI-Model'
}

{ #category : #comparing }
IceTipRemoteModel >> = anotherModel [

	self species = anotherModel species ifFalse: [ ^ false ].
	
	^ entity = anotherModel entity
]

{ #category : #accessing }
IceTipRemoteModel >> branches [
	^ self entity branches
]

{ #category : #accessing }
IceTipRemoteModel >> description [

	^ '{1} <{2}>' format: { self name. self entity url }
]

{ #category : #accessing }
IceTipRemoteModel >> name [
	^ self entity name
]

{ #category : #actions }
IceTipRemoteModel >> newDeleteAction [
	<noCache>
	
	^ IceTipStandardAction new
		repository: self repositoryModel entity;
		message: ('Removing remote {1}' format: { self name });
		onSuccessRepositoryModified;
		action: [ self repositoryModel entity removeRemote: self entity ];
		yourself
]

{ #category : #actions }
IceTipRemoteModel >> newFetchAction [
	<noCache>
	
	^ IceTipStandardAction new
		repository: self repositoryModel entity;
		message: ('Fetching remote {1}' format: { self name });
		onSuccessRepositoryModified;
		action: [ self entity fetch ];
		yourself
]
