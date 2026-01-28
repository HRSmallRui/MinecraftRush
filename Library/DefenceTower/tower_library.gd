extends Resource
class_name DefenceTowerLibrary

static var archer_datas: Array[BasedTowerData] = [
	BasedTowerData.new("射手高台","弓箭手站在高台上，打击来犯的敌人。",4,6,0.8,280),
	BasedTowerData.new("大师射手高台","更加精通箭术的射手大师，能造成更多的伤害。",7,11,0.6,320),
	BasedTowerData.new("皇家射手高台","经受过专业训练的皇帝贴身射手护卫，誓死捍卫帝国的领土，坚决不让敌人踏足土地一步。",
	10,16,0.5,360),
	BasedTowerData.new("投石高塔","只要喝饱暗黑重油，这些紫皮投石手便会重拳出击，将敌人压在巨石之下。",45,63,1.5,360),
	BasedTowerData.new("沙漠哨塔","沙漠中的刺客，手中的飞刃时刻瞄准着敌人的头颅，每次都有可能对敌人造成致命的伤害。",23,45,0.8,400),
	BasedTowerData.new("劫掠哨塔","被顶层同类长期压迫的低等刌民奋起反抗，将怒火泄于战场，对同为刌民的帮凶敌人，每发箭矢都直击要害。",13,20,0.4,500)
]

static var barrack_datas: Array[BarrackTowerData] = [
	BarrackTowerData.new("民兵兵营","三个顽强的民兵，可以阻拦敌人并造成伤害。",50,1,3,0,10),
	BarrackTowerData.new("步兵兵营","步兵拥有更加精良的装备，他们是帝国抵抗外敌入侵的中流砥柱。",100,3,5,0.1,10),
	BarrackTowerData.new("骑士兵营","身披重装铠甲的强大骑士，他们身先士卒，全力阻挡敌军的入侵。",150,6,10,0.3,10),
	BarrackTowerData.new("皇家近卫军","他们是帝国最强的战士，绝对效忠于皇族，更是皇帝陛下最坚实的后盾。",200,12,15,0.65,14),
	BarrackTowerData.new("大刀教会","在最恶劣的环境成长的最强大的战士，他们所信仰的神明赐予他们奇异强大的力量，来犯的敌军无一不会在其大刀面前战栗不止。",
	300,20,30,0,12),
	BarrackTowerData.new("医疗护卫队","反抗厌鸣统治的组织，成员皆是曾任职实验室的医疗生化专家，觉醒倒戈后，予世人希望，予敌军绝望。",250,7,12,0.3,10)
]

static var magic_datas: Array[BasedTowerData] = [
	BasedTowerData.new("法师塔","魔法师可以发射魔法飞弹，渗透护甲对敌人造成伤害。",9,17,1.5,280),
	BasedTowerData.new("法师高台","更强的魔法能量，法师发射的强化魔法球能够撕裂护甲和血肉。",23,43,1.5,320),
	BasedTowerData.new("风暴法师塔","集结帝国之力和风暴水晶的能量，法师的能力的已得到最大化强化，攻击使敌人魂飞魄散。",
	40,74,1.5,360),
	BasedTowerData.new("守卫者教堂","圣焰一开始微光摇曳，神父以时间为引，微弱的火苗逐渐成长为燎原烈火。",
	3,6,3,400),
	BasedTowerData.new("女巫高塔","当地冤屈的女巫，解放后以致命魔法回馈救赎，攻击附带恶毒诅咒。",17,28,1.5,370),
	BasedTowerData.new("炼金术士","隐居世间的科学怪人，总是迫不及待地想要实验自己的新药水。",45,80,1.5,380)
]

static var bombard_datas : Array[BasedTowerData] = [
	BasedTowerData.new("烟花发射台","红石驱动的兵器，可以发射烟花造成爆炸，对地面敌人造成范围伤害。",8,15,3,320),
	BasedTowerData.new("红石火炮","从不痛不痒的烟花改为发射TNT，可以造成更高的伤害。",20,40,3,320),
	BasedTowerData.new("红石高炮","炮弹进一步改良升级为巨型TNT，可以轰炸更大的区域，敌人毫无生存希望。",30,60,3,360),
	BasedTowerData.new("演算者炮塔","它们来自未知，它们是谁，为什么要参与进来帮助我们，至今仍是个谜。它们自称远古的使者，使用未知的超自然武器进行恐怖的火力压制。",
	25,36,1.5,320),
	BasedTowerData.new("湮灭炮塔","人族科技巅峰之作！以高能液体为动力的终极炮塔，可倾泻毁灭性火力，不过维护成本相当昂贵。",
	100,200,5,400),
	BasedTowerData.new("投石机","帝国工程师的最新力作，利用岩浆与水混合不断产生的圆石进行范围打击，每次攻击都会让敌人暂缓脚步。",
	50,100,3,360)
]


static var buying_soldier_datas: Dictionary = {
	"DesertSoldier1": BarrackTowerData.new("沙漠佣兵","另一伙沙漠游牧部落的常规士兵，他们不止为钱，还为了，正义！",160,10,15,0,0),
	"DesertSoldier2": BarrackTowerData.new("佣兵头领","这伙亡命之徒的头头，“战斗”与“金钱”是他们的信仰，但请他们出动需要更多的代价……",380,20,35,0.5,0),
}
