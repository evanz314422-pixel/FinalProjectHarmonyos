import { router, promptAction } from '@kit.ArkUI';
import {
  currentSession,
  deviceStatus,
  getCurrentUser,
  HealthMetric,
  healthAlerts,
  healthMetrics,
  historyRecords,
  markFirstPendingRecordDone,
  medicines,
  MedicationPlan,
  MedicationRecord,
  Medicine,
  plans,
  todayRecords
} from '../models/AppData';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State refreshToken: number = 0;

  private completionText(): string {
    let done: number = 0;
    for (let index = 0; index < todayRecords.length; index++) {
      if (todayRecords[index].status === '已服用') {
        done++;
      }
    }
    return done.toString() + '/' + todayRecords.length.toString();
  }

  private doneCount(): number {
    let done: number = 0;
    for (let index = 0; index < todayRecords.length; index++) {
      if (todayRecords[index].status === '已服用') {
        done++;
      }
    }
    return done;
  }

  private adherencePercent(): number {
    if (todayRecords.length === 0) {
      return 0;
    }
    return Math.round(this.doneCount() * 100 / todayRecords.length);
  }

  private hasPendingRecord(): boolean {
    for (let index = 0; index < todayRecords.length; index++) {
      if (todayRecords[index].status !== '已服用') {
        return true;
      }
    }
    return false;
  }

  private nextDoseRecord(): MedicationRecord {
    for (let index = 0; index < todayRecords.length; index++) {
      if (todayRecords[index].status !== '已服用') {
        return todayRecords[index];
      }
    }
    if (todayRecords.length > 0) {
      return todayRecords[0];
    }
    return { elderId: 1, time: '--:--', medicineName: '暂无用药任务', status: '已服用' };
  }

  private lowStockText(): string {
    return this.lowStockCount().toString() + '种';
  }

  private lowStockCount(): number {
    let count: number = 0;
    for (let index = 0; index < medicines.length; index++) {
      if (medicines[index].stock <= medicines[index].threshold) {
        count++;
      }
    }
    return count;
  }

  private lowStockWarningText(): string {
    if (this.lowStockCount() === 0) {
      return '当前常用药库存充足。';
    }
    return '有 ' + this.lowStockCount().toString() + ' 种药快吃完，请及时补充或让家属帮忙处理。';
  }

  private latestHeartRateText(): string {
    for (let index = 0; index < healthMetrics.length; index++) {
      if (healthMetrics[index].type === 'heartRate') {
        return healthMetrics[index].value;
      }
    }
    return '暂无数据';
  }

  private latestHeartRateNormal(): boolean {
    for (let index = 0; index < healthMetrics.length; index++) {
      if (healthMetrics[index].type === 'heartRate') {
        return healthMetrics[index].normal;
      }
    }
    return true;
  }

  private exitLogin(): void {
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  private statusLabel(status: string): string {
    if (status === '已服用') {
      return '已完成';
    }
    if (status === '漏服') {
      return '需补记';
    }
    if (status === '延迟服用') {
      return '已延迟';
    }
    return '待服用';
  }

  private statusColor(status: string): string {
    if (status === '已服用') {
      return '#0B7A5B';
    }
    if (status === '漏服') {
      return '#B42318';
    }
    if (status === '延迟服用') {
      return '#C56A16';
    }
    return '#D97706';
  }

  private completeNextDose(): void {
    if (!this.hasPendingRecord()) {
      promptAction.showToast({ message: '今天的用药已经全部完成' });
      return;
    }
    markFirstPendingRecordDone();
    this.refreshToken++;
    promptAction.showToast({ message: '已记录服药，家属端会同步看到状态' });
  }

  build() {
    if (currentSession.role === 'guardian') {
      this.GuardianTabs()
    } else {
      this.ElderTabs()
    }
  }

  @Builder ElderTabs() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
      TabContent() {
        this.ElderTodayTab()
      }
      .tabBar(this.NavItem('今日', '任务', 0))

      TabContent() {
        this.ElderMedicineTab()
      }
      .tabBar(this.NavItem('药品', '库存', 1))

      TabContent() {
        this.ElderHealthTab()
      }
      .tabBar(this.NavItem('健康', '指标', 2))

      TabContent() {
        this.ElderMineTab()
      }
      .tabBar(this.NavItem('我的', '设置', 3))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .animationDuration(180)
    .backgroundColor('#F6F8F7')
    .onChange((index: number) => {
      this.currentTab = index;
    })
  }

  @Builder GuardianTabs() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
      TabContent() {
        this.GuardianWatchTab()
      }
      .tabBar(this.NavItem('看护', '总览', 0))

      TabContent() {
        this.GuardianMedicineTab()
      }
      .tabBar(this.NavItem('药品', '代管', 1))

      TabContent() {
        this.GuardianHealthTab()
      }
      .tabBar(this.NavItem('健康', '告警', 2))

      TabContent() {
        this.GuardianRecordTab()
      }
      .tabBar(this.NavItem('记录', '服药', 3))

      TabContent() {
        this.GuardianSettingTab()
      }
      .tabBar(this.NavItem('设置', '绑定', 4))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .animationDuration(180)
    .backgroundColor('#F5F7FA')
    .onChange((index: number) => {
      this.currentTab = index;
    })
  }

  @Builder ElderTodayTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('安心服药助手', '把今天最重要的用药任务放在最前面，少找一步，少漏一次。')
        this.NextDoseCard()
        this.AlertCard()

        Row({ space: 12 }) {
          this.SummaryCard('今日完成', this.completionText(), '#0B7A5B')
          this.SummaryCard('心率状态', this.latestHeartRateText(), this.latestHeartRateNormal() ? '#0B7A5B' : '#B42318')
          this.SummaryCard('低库存', this.lowStockText(), '#C56A16')
        }
        .width('100%')

        this.ProgressCard()
        this.SectionTitle('今日药单')
        ForEach(todayRecords, (item: MedicationRecord) => {
          this.TaskRow(item)
        }, (item: MedicationRecord) => item.time + item.medicineName + item.status + this.refreshToken.toString())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder ElderMedicineTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('药品管理', '先看库存，再按需要拍照录药或查看长期计划。')
        this.LowStockNotice()
        Row({ space: 10 }) {
          this.ActionButton('拍照录药', 'pages/AddMedicinePage')
        }
        .width('100%')
        Row({ space: 8 }) {
          this.QuickEntry('药品库', '常用药', 'pages/MedicineLibraryPage')
          this.QuickEntry('库存管理', '快吃完', 'pages/InventoryPage')
          this.QuickEntry('用药计划', '时间表', 'pages/PlanListPage')
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('看不清药盒？拍照帮你识别')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('适合药名太小、包装看不清时使用。识别结果仍需本人或家属核对。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#52635F')
          Button('问用药问题')
            .width('100%')
            .height(50)
            .borderRadius(18)
            .fontColor('#0B7A5B')
            .backgroundColor('#FFFFFF')
            .onClick(() => router.pushUrl({ url: 'pages/AIAssistantPage' }))
        }
        .width('100%')
        .padding(18)
        .borderRadius(24)
        .backgroundColor('#E7F5EF')
        .alignItems(HorizontalAlign.Start)

        this.SectionTitle('用药计划')
        ForEach(plans, (plan: MedicationPlan) => {
          this.PlanRow(plan)
        }, (plan: MedicationPlan) => plan.id.toString())

        this.SectionTitle('常用药品')
        ForEach(medicines, (item: Medicine) => {
          this.MedicineRow(item)
        }, (item: Medicine) => item.id.toString() + item.stock.toString())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder ElderHealthTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('健康监测', '先看异常，再记录血压、血糖和心率。')
        this.DeviceCard()
        this.AlertCard()
        this.HealthActionCard()
        this.SectionTitle('最近指标')
        ForEach(healthMetrics, (item: HealthMetric) => {
          this.HealthRow(item.name, item.value, item.time, item.normal)
        }, (item: HealthMetric) => item.name + item.time + item.value)
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder ElderMineTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('我的', '账号绑定、字体和提醒设置。')
        Column({ space: 10 }) {
          Text(getCurrentUser().name)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('老人绑定码：AX2026')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0B7A5B')
          Text('把这个码给家属看。家属绑定后，可以帮你查看用药记录和健康告警。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#52635F')
        }
        .width('100%')
        .padding(20)
        .borderRadius(26)
        .backgroundColor('#FFFFFF')
        .alignItems(HorizontalAlign.Start)

        this.EntryRow('家属绑定设置', '查看绑定状态和异常通知', 'pages/FamilyAssistPage')
        this.EntryRow('大字模式', '调大字体，看得更清楚', 'pages/SettingsPage')
        this.EntryRow('强提醒模式', '铃声、震动和稍后提醒', 'pages/SettingsPage')
        this.EntryRow('紧急联系人', '身体不舒服时快速联系家属', 'pages/FamilyAssistPage')
        this.EntryRow('我的设置', '本地备份和更多设置', 'pages/SettingsPage')
        Button('退出登录')
          .width('100%')
          .height(52)
          .fontSize(19)
          .borderRadius(20)
          .fontColor('#B42318')
          .backgroundColor('#FFF1F0')
          .onClick(() => this.exitLogin())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianWatchTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('照护看板', '李女士正在看护张阿姨')
        this.AlertCard()
        Row({ space: 12 }) {
          this.SummaryCard('今日服药', this.completionText(), '#0B7A5B')
          this.SummaryCard('心率', this.latestHeartRateText(), this.latestHeartRateNormal() ? '#0B7A5B' : '#B42318')
          this.SummaryCard('低库存', this.lowStockText(), '#C56A16')
        }
        .width('100%')
        Column({ space: 10 }) {
          Text('AI 照护摘要')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('中午 12:30 的二甲双胍片尚未确认；心率最近一次为 116 次/分，已模拟通知监护人。建议稍后电话确认老人状态。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#52635F')
          Button('生成提醒话术')
            .width('100%')
            .height(48)
            .borderRadius(18)
            .backgroundColor('#0B7A5B')
            .onClick(() => router.pushUrl({ url: 'pages/AIAssistantPage' }))
        }
        .width('100%')
        .padding(18)
        .borderRadius(24)
        .backgroundColor('#FFFFFF')
        .alignItems(HorizontalAlign.Start)

        this.SectionTitle('今日药单')
        ForEach(todayRecords, (item: MedicationRecord) => {
          this.TaskRow(item)
        }, (item: MedicationRecord) => item.time + item.medicineName + item.status + this.refreshToken.toString())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianMedicineTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('代管药品', '监护人可以替老人录入药品和维护计划')
        Row({ space: 12 }) {
          this.ActionButton('替老人加药', 'pages/AddMedicinePage')
          this.ActionButton('新增计划', 'pages/AddPlanPage')
        }
        .width('100%')
        Row({ space: 12 }) {
          this.ActionButton('库存管理', 'pages/InventoryPage')
          this.ActionButton('药品库', 'pages/MedicineLibraryPage')
        }
        .width('100%')

        this.SectionTitle('张阿姨的药品')
        ForEach(medicines, (item: Medicine) => {
          this.MedicineRow(item)
        }, (item: Medicine) => item.id.toString() + item.stock.toString())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianHealthTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('健康监护', '关注手环同步和生命体征异常')
        this.DeviceCard()
        this.AlertCard()
        this.SectionTitle('健康指标')
        ForEach(healthMetrics, (item: HealthMetric) => {
          this.HealthRow(item.name, item.value, item.time, item.normal)
        }, (item: HealthMetric) => item.name + item.time + item.value)
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianRecordTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('服药记录', '查看已服、漏服和延迟服用情况')
        Row({ space: 12 }) {
          this.ActionButton('统计分析', 'pages/StatsPage')
          this.ActionButton('历史记录', 'pages/HistoryPage')
        }
        .width('100%')
        this.SectionTitle('最近记录')
        ForEach(historyRecords, (item: MedicationRecord) => {
          this.RecordRow(item)
        }, (item: MedicationRecord) => item.time + item.medicineName + item.status)
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianSettingTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('绑定与通知', '管理老人账号关联和异常提醒')
        Column({ space: 10 }) {
          Text('已绑定老人：张阿姨')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('关系：女儿    绑定码：AX2026')
            .fontSize(17)
            .fontColor('#52635F')
          Text('漏服、低库存和心率异常会在监护人端显示应用内告警。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#52635F')
        }
        .width('100%')
        .padding(20)
        .borderRadius(26)
        .backgroundColor('#FFFFFF')
        .alignItems(HorizontalAlign.Start)

        this.EntryRow('管理绑定与通知', '绑定老人、通知开关和紧急联系人', 'pages/FamilyAssistPage')
        this.EntryRow('我的设置', '监护人通知和本地备份设置', 'pages/SettingsPage')
        Button('退出登录')
          .width('100%')
          .height(52)
          .fontSize(19)
          .borderRadius(20)
          .fontColor('#B42318')
          .backgroundColor('#FFF1F0')
          .onClick(() => this.exitLogin())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder AlertCard() {
    Column({ space: 10 }) {
      Row() {
        Text(healthAlerts.length > 0 ? '需要关注' : '状态平稳')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(healthAlerts.length > 0 ? '#B42318' : '#0B7A5B')
        Blank()
        Text(healthAlerts.length > 0 ? '已通知' : '正常')
          .fontSize(14)
          .fontColor(healthAlerts.length > 0 ? '#B42318' : '#0B7A5B')
      }
      .width('100%')
      Text(healthAlerts.length > 0 ? healthAlerts[0].title + '：' + healthAlerts[0].value + '，建议稍后复测或联系家属。' : '今天暂未发现心率、血压或血糖异常。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(healthAlerts.length > 0 ? '#FFF1F0' : '#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder NextDoseCard() {
    Column({ space: 14 }) {
      Row() {
        Text(this.hasPendingRecord() ? '下一次服药' : '今日已完成')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor('#102A27')
        Blank()
        this.SmallBadge(this.statusLabel(this.nextDoseRecord().status), this.statusColor(this.nextDoseRecord().status), '#FFFFFF')
      }
      .width('100%')
      Text(this.nextDoseRecord().time)
        .fontSize(44)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0B7A5B')
      Text(this.nextDoseRecord().medicineName)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(this.hasPendingRecord() ? '请按医嘱确认后服用。完成后点“我已吃药”，家属端会同步状态。' : '今天的用药任务都完成了，可以继续查看健康指标。')
        .fontSize(17)
        .lineHeight(26)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button(this.hasPendingRecord() ? '我已吃药' : '查看记录')
          .layoutWeight(1)
          .height(56)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .backgroundColor('#0B7A5B')
          .onClick(() => this.completeNextDose())
        Button('稍后提醒')
          .layoutWeight(1)
          .height(56)
          .fontSize(19)
          .borderRadius(18)
          .fontColor('#0B7A5B')
          .backgroundColor('#FFFFFF')
          .onClick(() => router.pushUrl({ url: 'pages/ReminderDetailPage' }))
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ProgressCard() {
    Column({ space: 12 }) {
      Row() {
        Text('今日完成率')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text(this.adherencePercent().toString() + '%')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0B7A5B')
      }
      .width('100%')
      Progress({ value: this.adherencePercent(), total: 100, type: ProgressType.Linear })
        .width('100%')
        .color('#0B7A5B')
      Text(this.hasPendingRecord() ? '还有未确认的服药任务，建议完成后再查看晚间计划。' : '今天计划已经完成，继续保持。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder LowStockNotice() {
    Column({ space: 8 }) {
      Row() {
        Text(this.lowStockCount() > 0 ? '低库存提醒' : '库存状态')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.lowStockCount() > 0 ? '#B54708' : '#0B7A5B')
        Blank()
        this.SmallBadge(this.lowStockText(), this.lowStockCount() > 0 ? '#B54708' : '#0B7A5B', this.lowStockCount() > 0 ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
      Text(this.lowStockWarningText())
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(this.lowStockCount() > 0 ? '#FFF7E8' : '#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder HealthActionCard() {
    Column({ space: 12 }) {
      Text(healthAlerts.length > 0 ? '异常处理建议' : '健康记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(healthAlerts.length > 0 ? '#B42318' : '#14213D')
      Text(healthAlerts.length > 0 ? '心率偏高时先坐下休息，几分钟后复测一次；如果仍不舒服，及时联系家属。' : '没有异常时，定期记录血压、血糖和心率即可。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button(healthAlerts.length > 0 ? '复测一次' : '记录指标')
          .layoutWeight(1)
          .height(52)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .backgroundColor('#0B7A5B')
          .onClick(() => router.pushUrl({ url: 'pages/HealthMetricPage' }))
        Button('联系家属')
          .layoutWeight(1)
          .height(52)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .fontColor('#B42318')
          .backgroundColor('#FFF1F0')
          .onClick(() => router.pushUrl({ url: 'pages/FamilyAssistPage' }))
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder DeviceCard() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(deviceStatus.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text(deviceStatus.connected ? '已连接，' + deviceStatus.lastSync : '未连接，点击健康页模拟连接')
            .fontSize(16)
            .fontColor('#52635F')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(deviceStatus.battery.toString() + '%')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0B7A5B')
      }
      .width('100%')
      Button('进入手环连接')
        .width('100%')
        .height(48)
        .borderRadius(18)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => router.pushUrl({ url: 'pages/HealthMetricPage' }))
    }
    .width('100%')
    .padding(18)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder HeaderBlock(title: string, subtitle: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
      Text(subtitle)
        .fontSize(18)
        .lineHeight(26)
        .fontColor('#52635F')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder NavItem(title: string, subtitle: string, index: number) {
    Column({ space: 2 }) {
      Text(title)
        .fontSize(17)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.currentTab === index ? '#0B7A5B' : '#52635F')
      Text(subtitle)
        .fontSize(12)
        .fontColor(this.currentTab === index ? '#0B7A5B' : '#8A9A96')
    }
    .width(66)
    .height(52)
    .borderRadius(18)
    .backgroundColor(this.currentTab === index ? '#E7F5EF' : '#FFFFFF')
    .justifyContent(FlexAlign.Center)
  }

  @Builder SectionTitle(title: string) {
    Text(title)
      .fontSize(22)
      .fontWeight(FontWeight.Bold)
      .fontColor('#14213D')
      .width('100%')
  }

  @Builder SummaryCard(title: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
      Text(title)
        .fontSize(15)
        .fontColor('#52635F')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(108)
    .padding(12)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
  }

  @Builder ActionButton(title: string, url: string) {
    Button(title)
      .layoutWeight(1)
      .height(54)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .borderRadius(20)
      .backgroundColor('#0B7A5B')
      .onClick(() => router.pushUrl({ url: url }))
  }

  @Builder QuickEntry(title: string, desc: string, url: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0B7A5B')
        .maxLines(1)
      Text(desc)
        .fontSize(13)
        .fontColor('#667085')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(76)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .onClick(() => router.pushUrl({ url: url }))
  }

  @Builder TaskRow(item: MedicationRecord) {
    Row() {
      Column({ space: 5 }) {
        Text(item.time)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.medicineName)
          .fontSize(17)
          .fontColor('#52635F')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      this.SmallBadge(this.statusLabel(item.status), this.statusColor(item.status), item.status === '已服用' ? '#E7F5EF' : '#FFF7E8')
    }
    .width('100%')
    .padding(18)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
  }

  @Builder MedicineRow(item: Medicine) {
    Column({ space: 8 }) {
      Row() {
        Text(item.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
          .maxLines(1)
        Blank()
        this.SmallBadge(item.stock <= item.threshold ? '快吃完' : '充足', item.stock <= item.threshold ? '#B54708' : '#0B7A5B', item.stock <= item.threshold ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
      Text(item.spec + '  默认 ' + item.dosage)
        .fontSize(17)
        .fontColor('#52635F')
      Text('库存 ' + item.stock.toString() + '，' + item.note)
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => router.pushUrl({ url: 'pages/MedicineDetailPage' }))
  }

  @Builder PlanRow(plan: MedicationPlan) {
    Column({ space: 8 }) {
      Row() {
        Text(plan.medicineName)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
          .maxLines(1)
        Blank()
        this.SmallBadge(plan.enabled ? '启用' : '暂停', plan.enabled ? '#0B7A5B' : '#667085', plan.enabled ? '#E7F5EF' : '#F2F4F7')
      }
      .width('100%')
      Text(plan.times.join(' / '))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0B7A5B')
      Text(plan.dosage + '  ' + plan.mealTime)
        .fontSize(17)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => router.pushUrl({ url: 'pages/PlanDetailPage' }))
  }

  @Builder RecordRow(item: MedicationRecord) {
    Row() {
      Column({ space: 5 }) {
        Text(item.time)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.medicineName)
          .fontSize(16)
          .fontColor('#52635F')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      this.SmallBadge(this.statusLabel(item.status), this.statusColor(item.status), item.status === '漏服' ? '#FFF1F0' : '#E7F5EF')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
  }

  @Builder HealthRow(name: string, value: string, time: string, normal: boolean) {
    Row() {
      Column({ space: 5 }) {
        Text(name)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(time)
          .fontSize(15)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Column({ space: 4 }) {
        Text(value)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(normal ? '#0B7A5B' : '#B42318')
        Text(normal ? '正常' : '异常')
          .fontSize(14)
          .fontColor(normal ? '#0B7A5B' : '#B42318')
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(normal ? '#FFFFFF' : '#FFF1F0')
  }

  @Builder EntryRow(title: string, desc: string, url: string) {
    Row() {
      Column({ space: 5 }) {
        Text(title)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(desc)
          .fontSize(16)
          .fontColor('#52635F')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text('进入')
        .fontSize(16)
        .fontColor('#0B7A5B')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .onClick(() => router.pushUrl({ url: url }))
  }

  @Builder SmallBadge(text: string, color: string, bgColor: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(14)
      .backgroundColor(bgColor)
  }
}
