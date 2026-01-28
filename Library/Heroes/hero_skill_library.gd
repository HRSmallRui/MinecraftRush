extends Resource
class_name HeroSkillLibrary


static var hero_skill_data_library: Dictionary = {
	##史蒂夫
	0:[
		[
			[0.1,0.2,0.3] #0:总伤减免
		],
		[
			[20,40,60] #0：提高生命值
		],
		[
			[70,84,100], #0：伤害下限
			[82,96,122], #1：伤害上限
			[0.1,0.2,0.3], #2:削减护甲
			12 #3:CD
		],
		[
			[200,250,300], #0：回复生命值
			[8,10,12], #1：回血持续时间
			20 #2：CD
		],
		[
			[216,374,524], #0:单次伤害
			[8,12,16], #1:流血时间
			[0.04,0.08,0.12], #2:斩杀阈值
			24 #3：CD
		],
		[
			[2,4,6,8] #0:药水数量
		]
	],
	
	##法辰
	1:[
		{
			"extra_damage": [5,10,15]
		},
		{
			"upgrade_damage": [4,6,8]
		},
		{
			"CD": 24,
			"sheild_duration": [4,5,6]
		},
		{
			"CD": 26,
			"magic_ball_count": [4,6,8],
			"damage": 160
		},
		{
			"CD": 18,
			"skill_duration": 3,
			"damage_per_count": [4,6,8]
		},
		{
			"CD": 45,
			"damage": 120,
			"count": [4,6,8,10]
		}
	],
	
	##艾利克斯
	2:[
		{
			"immune_possible": [0.2,0.3,0.4]
		},
		{
			"CD": 16,
			"lightning_damage": [128,156,212]
		},
		{
			"CD": 30,
			"armor": 0.9,
			"duration": [6,8,10]
		},
		{
			"CD": 12,
			"damage_low": [72,86,96],
			"damage_high": [144,172,216]
		},
		{
			"CD": 20,
			"first_damage": [164,196,246],
			"duration": [4,6,8],
			"damage_per_count": 8
		},
		{
			"CD": 42,
			"count": [6,8,10,12],
			"damage_per_count": 80,
			"explosion_damage": [126,168,210,252]
		}
	],
	
	##塔尔辛
	3:[
		{},
		{
			"CD": 30,
			"damage_percentage": [0.4,0.5,0.6]
		},
		{
			"CD": 20,
			"duration": 12,
			"damage_per_count": [6,8,10]
		},
		{
			"broken_rate": [0.01,0.02,0.03]
		},
		{
			"penetrate_count": [1,2,3]
		},
		{
			"CD": [120,100,80,60],
			"damage": [500,750,1000,1300]
		}
	],
	
	##鲁伯特
	4:[
		{
			"damage_low": [7,10,15],
			"damage_high": [10,20,30]
		},
		{
			"CD": 16,
			"moving_time": [2,4,6],
			"dizness_time": 1
		},
		{
			"CD": 26,
			"damage_low": [125,142,172],
			"damage_high": [150,186,214],
			"during_time": [4,6,8],
			"dot_damage": 12
		},
		{
			"CD": 18,
			"damage_low": [40,56,72],
			"damage_high": [72,94,108],
			"dizness_time": [2,3,4]
		},
		{
			"upgrade_damage": [4,6,8],
			"during_time": 4,
			"upgrade_rate": [1.5,1.75,2]
		},
		{
			"CD": 50,
			"lightning_count": [3,4,5,6],
			"damage_low": 50,
			"damage_high": 75,
			"storm_during_time": [4,5,6,8],
			"slow_rate": 0.6
		}
	],
	
	##塞勒姆
	7:[
		{
			
		},
		{
			"explosion_damage": [10,20,30]
		},
		{
			"CD": 32,
			"plugin_layers": 2,
			"damage": [150,200,250]
		},
		{
			"aoe_damage": [3,6,9],
		},
		{
			"CD": 28,
			"plugin_layers": 3,
			"damage_low": [100,124,156],
			"damage_high": [230,256,304]
		},
		{
			"CD": 36,
			"existing_time": [10,12,14,16]
		}
	],
	
	##乔尼
	8:[
		{
			"broken_armor": [0.04,0.08]
		},
		{
			"heal_health": [1,2,3]
		},
		{
			"rotation_time": [2,3,4],
			"damage": 8,
			"CD":17
		},
		{
			"attack_time": 2,
			"damage": [8,10,12],
			"CD":18,
			"dizness_time": [2]
		},
		{
			"CD": 30,
			"dizness_time": 2,
			"damage_low": [310,400,510],
			"damage_high": [365,450,578],
			"heal_rate": [0.1,0.2,0.3]
		},
		{
			"CD": 40,
			"duration": [4,6,8,10]
		}
	],
	
	##迈克
	9:[
		{
			
		},
		{
			"CD": 14,
			"fire_count": [10,20,30],
			"damage_low": 100,
			"damage_high": 200,
			"second_damage": 450
		},
		{
			"CD": [20,18,16],
			"heal_rate": [0.2,0.4,0.6],
			"second_damage": [400,800,1200]
		},
		{
			"CD": 18,
			"damage": [120,160,200],
		},
		{
			"CD": [14,18,22],
			"stop_time": [4,8,12],
			"damage_rate": [0.4,0.5,0.6],
			"slow_duration": 6,
			"slow_rate": 0.1
		},
		{
			"CD": 32,
			"fire_count": [3,4,5,6],
			"fire_damage": 300,
			"water_damage": [100,200,300,400],
			"damage_low": [4,3,2,1],
			"damage_high": [8,6,4,2],
			"water_buff_duration": [4,6,8,10],
			"earth_damage": 400,
			"earth_count": [2,3,4,5],
			"wind_damage": [40,60,80,100],
			"slow_duration": [5,6,7,8]
		}
	]
}

static var hero_skill_price_library: Dictionary = {
	0: [ #史蒂夫
		[1,1,1],
		[2,2,2],
		[1,2,3],
		[4,4,4],
		[3,3,3]
	],
	1: [ #法辰
		[1,1,1],
		[2,2,3],
		[4,4,4],
		[2,2,2],
		[2,2,4]
	],
	2: [#艾利克斯
		[1,2,3],
		[1,2,3],
		[2,2,2],
		[3,3,3],
		[2,3,4]
	],
	3: [#塔尔辛
		[3,3,4],
		[1,2,3],
		[2,1,1],
		[2,2,3],
		[3,3,3]
	],
	5: [#空树林
		[2,2,2],
		[3,4,5],
		[2,2,3],
		[1,2,2],
		[2,2,2]
	],
	6 :[#金钻
		[2,2,3],
		[2,2,3],
		[2,2,3],
		[2,3,3],
		[2,2,3]
	],
	7:[#塞勒姆
		[3,2,2],
		[2,1,2],
		[3,2,1],
		[2,3,4],
		[3,3,3]
	],
	8:[#乔尼
		[2,2,2],
		[2,3,3],
		[2,2,3],
		[3,3,3],
		[1,2,3]
	],
	4: [#鲁伯特
		[2,3,3],
		[3,3,3],
		[2,2,3],
		[2,2,2],
		[2,2,2]
	],
	9:[#迈克
		[2,2,1],
		[2,2,2],
		[2,2,3],
		[3,3,3],
		[3,3,3]
	]
}
