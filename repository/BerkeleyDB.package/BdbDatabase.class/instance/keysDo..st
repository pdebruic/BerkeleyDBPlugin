enumeration
keysDo: aBlock 
	"WARNING: If you have a large database this could take a long time!"
	"Evaluate aBlock for each of the receiver's keys."

	self associationsDo: [:association | aBlock value: association key]