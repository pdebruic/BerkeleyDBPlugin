as yet unclassified
baseline: spec
    <baseline>
    spec
        for: #'common'
        do: [ 
            spec package:'BerkeleyDB'.
		spec package:'BerkeleyDBPlugin' with:[spec requires:'VMMaker'].
		spec group:'Core' with: #('BerkeleyDB'); 
			  group: 'default' with: #('Core')
].