"
I'm a panel to peform the merge of an existing branch.
"
Class {
	#name : #IceTipMergeBranchPanel,
	#superclass : #IceTipExistingBranchPanel,
	#instVars : [
		'mergeType'
	],
	#category : #'Iceberg-TipUI-View-Branch'
}

{ #category : #accessing }
IceTipMergeBranchPanel >> beSwitchAndMerge [

	self mergeType: IceTipMergeType switchAndMerge
]

{ #category : #actions }
IceTipMergeBranchPanel >> doAccept [

	IceTipStandardAction new
		repository: self model entity; 
		message: ('Verifying merge from {1}' format: { self selectedBranch name });
		onSuccess: [ self selectedBranch previewMerge: self mergeType ];
		action: [ self validate ];
		executeWithContext: self
]

{ #category : #accessing }
IceTipMergeBranchPanel >> mergeType [

	^ mergeType ifNil: [ IceTipMergeType default ]
]

{ #category : #accessing }
IceTipMergeBranchPanel >> mergeType: anObject [

	mergeType := anObject
]

{ #category : #accessing }
IceTipMergeBranchPanel >> withoutHead [

	self branchesList items: (self branchModels reject: #isHead).
	self branchesList selectIndex: 1
]
