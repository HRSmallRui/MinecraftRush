extends Resource
class_name StageLimitLibrary

static var limit_tech_levels = [
	1,2,2,2,3,
	3,3,4,4,5,
	5,5,5,5,5,
	5,5,5,5,5
]

static var can_use_tower_type = [
	[false,true,true,false],
	[true,false,false,true],
	[true,true,true,false],
	[false,true,false,false],
	
	[true,false,true,false],
	[true,true,false,false],
	[true,true,true,false],
	
	[false,true,false,true],
	[true,false,false,false],
	[true,true,false,false],
	[false,false,false,true],
	
	[false,true,true,false],
	[true,true,true,false],
	[true,false,true,false],
	[true,false,true,true],
	
	[false,true,false,true],
	[true,false,true,false],
	
	[true,true,false,true],
	[false,true,false,true],
	[true,true,false,true]
]
