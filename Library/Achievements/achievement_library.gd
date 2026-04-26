extends Resource
class_name AchievementLibrary

static var achievement_library: Dictionary = {
	"MR1": AchievementStruct.new("欢迎来到MinecraftRush","进入任意一关进行游玩。"),
	"FirstBlood": AchievementStruct.new("第一滴血","消灭一个敌人。"),
	"Level1Finished": AchievementStruct.new("塔防新手的试炼","第一关战役模式三星通关。"),
	"SearchInformation": AchievementStruct.new("收集党","打开至少6个新敌人信息卡。"),
	"TowerLV3": AchievementStruct.new("全家福","在第三关建造所有三级防御塔。"),
	"SheepDead": AchievementStruct.new("乔 詹金斯的愤怒","点爆10只绵羊。"),
	"Boss1Dead": AchievementStruct.new("终究是自诩","击败尸国统帅。"),
	"RoyalDefender": AchievementStruct.new("帝国捍卫者","在第一章节与第六章节杀死至少2500个敌人。"),
	
	"RoyalGuardSkill1": AchievementStruct.new("斩立决","皇家近卫军发动皇家审判累计处决99个敌人。"),
	"RoyalGuardSkill2": AchievementStruct.new("不动壁垒","皇家近卫军抵挡远程攻击累计2000次。"),
	"Stage4": AchievementStruct.new("惩奸除恶","第四关不放过任何一个敌人突破据点。"),
	
	"PrayEvil": AchievementStruct.new("称霸世界之恶性","掠夺三颗魔核。"),
	"SuperSkeleton": AchievementStruct.new("次次爆头，好运连连","骷髅狙击塔累计触发猩红狙击箭10次。"),
	"Freddy": AchievementStruct.new("高薪工作","熊爷是你能调戏的？"),
	"WildRegionCleaner": AchievementStruct.new("野区清理者","在第二章节与第三章节杀死至少2000个敌人。"),
	"Bloody": AchievementStruct.new("嗜血","累计杀死800个敌人。"),
	"Killer": AchievementStruct.new("杀戮者","累计杀死2000个敌人。"),
	"Boss2Dead": AchievementStruct.new("TANK!","击败泰坦丧尸。"),
	"ChurchDust": AchievementStruct.new("尘归尘，土归土","让守卫者教堂尘解累计3333个敌人。"),
	"IronGolem": AchievementStruct.new("钢铁是怎样练成的","铁傀儡累计恢复40000生命。"),
	
	"SandHuman": AchievementStruct.new("我即沙，随风而散","让沙人融入沙漠。"),
	"DancingCat": AchievementStruct.new("Ankha Dance!","让埃及猫猫跳摇摆舞。（你游戏还要不要了？！）"),
	"Remilia": AchievementStruct.new("胃炎满满","找到威严扫地机器人。"),
	"SunAchieve": AchievementStruct.new("太阳！","沙漠关卡都是夜晚关卡。"),
	"OperatorLightning": AchievementStruct.new("雷霆，击碎黑暗！","演算者炮塔累计召唤666次闪电。"),
	"OperatorSeckill": AchievementStruct.new("电锯惊魂","让演算者机甲累计处决666名敌人。"),
	"DeSentrySeckill": AchievementStruct.new("一个好人在什么情况下会杀人？","让沙漠哨塔累计处决47名敌人。"),
	"EpeeRebirth": AchievementStruct.new("不生不灭，不垢不净","让一个大刀兵重复复活4次。"),
	"Boss3Dead": AchievementStruct.new("殊途同归","击败巨型尸壳。"),
	"DeathKill": AchievementStruct.new("死神","累计杀死20000个敌人。"),
	
	"TheForest": AchievementStruct.new("野外求生第二步","生火，可用于保暖、照亮黑夜或吓走敌人。"),
	"CARRION": AchievementStruct.new("罐装生涯","激怒培养罐中的生物。"),
	"Primary": AchievementStruct.new("我的图画本在哪里","收集三支不同颜色的蜡笔。"),
	"INSIDE": AchievementStruct.new("深入","找到潜水艇。"),
	"GAIA1": AchievementStruct.new("悲伤的沼泽","找到沼泽的八音盒并播放音乐。"),
	"Resident": AchievementStruct.new("三光进村，寸草不生","搜刮林地府邸全部战利品。"),
	#"L4D": AchievementStruct.new("你惊扰了Witch","激怒哭泣的Witch。"),
	"CurseDead": AchievementStruct.new("不死者的诅咒","累计杀死200个持有女巫高塔施加的“死亡诅咒”的敌人。"),
	"PluginPeople": AchievementStruct.new("瘟神","医疗护卫队的士兵累计感染2000名敌人。"),
	"MagicianGold": AchievementStruct.new("黄金雕像艺术锦标赛","将累计120名敌人变成金像。"),
	"Boss4Dead": AchievementStruct.new("旧日支配者","击败远古守卫者。"),
	"Boss4DeadPerfect": AchievementStruct.new("我们的死忠","在避免释放末日情况下击败远古守卫者。"),
	
	"Boss5Dead": AchievementStruct.new("他不是白王，我才是","击败LIVER。"),
	"Chapter5Lily": AchievementStruct.new("终焉的百合花","第16关战役模式不摘取任何一朵路边花。"),
	
	"kinito_pet": AchievementStruct.new("你会原谅我吗","成功删除KinitoPet。"),
	"DNA_time": AchievementStruct.new("刻在DNA里的时间","在下午4:04进入第20关。"),
	"GyakutenSaiban": AchievementStruct.new("一斤鸭梨！","找到律师徽章。"),
	"PrayGame2": AchievementStruct.new("永世献身之善性","配对两个POWER II的魔核。"),
	"Boss6Dead": AchievementStruct.new("男人只有在一切都结束后才能流泪","击败厌皇-尼古拉斯。"),
	"MAIN_END": AchievementStruct.new("你好，世界","完整观看完结尾动画。"),
	"campaign_end": AchievementStruct.new("旅途的终点？","完整通关主线关卡。"),
	"diamond!": AchievementStruct.new("钻石！","通关所有主线关卡的钻石挑战。"),
	"bedrock": AchievementStruct.new("世界基层","通关所有主线关卡的基岩挑战。"),
	"sb_beggar": AchievementStruct.new("等破解哥","这是一个塞我游戏里都嫌脏的成就。")
	#uid:692224551 硬撑重振全身撞击吧
}
