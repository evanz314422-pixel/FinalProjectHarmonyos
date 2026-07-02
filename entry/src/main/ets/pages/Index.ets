import { router, promptAction } from '@kit.ArkUI';
import {
  CareActionRecord,
  currentSession,
  deviceStatus,
  getCurrentElder,
  getCurrentUser,
  getElderCareActionRecords,
  getElderHealthAlerts,
  getElderHealthMetrics,
  getElderHistoryRecords,
  getElderMedicines,
  getElderPlans,
  getElderTodayRecords,
  getCurrentElderPreference,
  getMedicinePhotoColor,
  getMedicinePhotoLabel,
  getMedicinePhotoUri,
  HealthAlert,
  HealthMetric,
  isMedicinePhotoUploaded,
  markFirstPendingRecordDone,
  MedicationPlan,
  MedicationRecord,
  Medicine,
  notificationPreferences,
  NotificationPreference,
  selectMedicine,
  selectPlan,
  selectReminder,
  setNotificationPreference,
  startCreatePlan,
  addCareActionRecord,
  addRefillTodo,
  confirmFirstPendingRecordByGuardian,
  markHealthRetestRequested,
  setLargeTextMode,
  setStrongReminderMode,
  unlinkCurrentElder
} from '../models/AppData';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State refreshToken: number = 0;
  @State guardianRecordFilter: string = '全部';
  @State elderFamilyNotified: boolean = false;
  @State guardianHealthContacted: boolean = false;
  @State guardianLastCareLog: string = '当前存在未确认服药和健康异常，建议联系老人确认。';
  @State guardianEmergencyContact: string = '女儿 李女士 13800000002';
  @State guardianEscalationEnabled: boolean = true;
  @State unlinkConfirmVisible: boolean = false;
  @State authorizationVisible: boolean = false;
  @State phoneEditVisible: boolean = false;
  @State guardianPhoneDraft: string = '';

  private currentMedicines(): Medicine[] {
    this.refreshToken;
    return getElderMedicines();
  }

  private currentPlans(): MedicationPlan[] {
    return getElderPlans();
  }

  private currentTodayRecords(): MedicationRecord[] {
    return getElderTodayRecords();
  }

  private currentHistoryRecords(): MedicationRecord[] {
    return getElderHistoryRecords();
  }

  private currentHealthMetrics(): HealthMetric[] {
    return getElderHealthMetrics();
  }

  private currentHealthAlerts(): HealthAlert[] {
    return getElderHealthAlerts();
  }

  private elderLargeTextEnabled(): boolean {
    this.refreshToken;
    return getCurrentElderPreference().largeText;
  }

  private elderStrongReminderEnabled(): boolean {
    this.refreshToken;
    return getCurrentElderPreference().strongReminder;
  }

  private currentCareActions(): CareActionRecord[] {
    this.refreshToken;
    return getElderCareActionRecords();
  }

  private completionText(): string {
    let done: number = 0;
    const records: MedicationRecord[] = this.currentTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '已服用') {
        done++;
      }
    }
    return done.toString() + '/' + records.length.toString();
  }

  private doneCount(): number {
    let done: number = 0;
    const records: MedicationRecord[] = this.currentTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '已服用') {
        done++;
      }
    }
    return done;
  }

  private adherencePercent(): number {
    const records: MedicationRecord[] = this.currentTodayRecords();
    if (records.length === 0) {
      return 0;
    }
    return Math.round(this.doneCount() * 100 / records.length);
  }

  private hasPendingRecord(): boolean {
    const records: MedicationRecord[] = this.currentTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status !== '已服用') {
        return true;
      }
    }
    return false;
  }

  private nextDoseRecord(): MedicationRecord {
    const records: MedicationRecord[] = this.currentTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status !== '已服用') {
        return records[index];
      }
    }
    if (records.length > 0) {
      return records[0];
    }
    return { elderId: 1, time: '--:--', medicineName: '暂无用药任务', status: '已服用' };
  }

  private lowStockText(): string {
    return this.lowStockCount().toString() + '种';
  }

  private lowStockCount(): number {
    let count: number = 0;
    const list: Medicine[] = this.currentMedicines();
    for (let index = 0; index < list.length; index++) {
      if (list[index].stock <= list[index].threshold) {
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
    const list: HealthMetric[] = this.currentHealthMetrics();
    for (let index = 0; index < list.length; index++) {
      if (list[index].type === 'heartRate') {
        return list[index].value;
      }
    }
    return '暂无数据';
  }

  private latestHeartRateNormal(): boolean {
    const list: HealthMetric[] = this.currentHealthMetrics();
    for (let index = 0; index < list.length; index++) {
      if (list[index].type === 'heartRate') {
        return list[index].normal;
      }
    }
    return true;
  }

  private latestMetricValue(type: string): string {
    const list: HealthMetric[] = this.currentHealthMetrics();
    for (let index = 0; index < list.length; index++) {
      if (list[index].type === type) {
        return list[index].value;
      }
    }
    return '暂无数据';
  }

  private latestMetricTime(type: string): string {
    const list: HealthMetric[] = this.currentHealthMetrics();
    for (let index = 0; index < list.length; index++) {
      if (list[index].type === type) {
        return list[index].time;
      }
    }
    return '--:--';
  }

  private healthRetestRequested(): boolean {
    const alerts: HealthAlert[] = this.currentHealthAlerts();
    return alerts.length > 0 && alerts[0].retestRequested === true;
  }

  private guardianOverviewStatus(): string {
    if (this.pendingDoseCount() > 0) {
      return '需确认服药';
    }
    if (this.currentHealthAlerts().length > 0) {
      if (this.healthRetestRequested()) {
        return '等待复测';
      }
      return '需复测健康';
    }
    if (this.hasUnarrangedLowStockMedicine()) {
      return '库存预警';
    }
    return '状态平稳';
  }

  private guardianOverviewColor(): string {
    if (this.pendingDoseCount() > 0 || (this.currentHealthAlerts().length > 0 && !this.healthRetestRequested())) {
      return '#B42318';
    }
    if (this.healthRetestRequested()) {
      return '#155EEF';
    }
    if (this.hasUnarrangedLowStockMedicine()) {
      return '#B54708';
    }
    return '#0B7A5B';
  }

  private guardianOverviewBgColor(): string {
    if (this.pendingDoseCount() > 0 || (this.currentHealthAlerts().length > 0 && !this.healthRetestRequested())) {
      return '#FFF1F0';
    }
    if (this.healthRetestRequested()) {
      return '#EAF2FF';
    }
    if (this.hasUnarrangedLowStockMedicine()) {
      return '#FFF7E8';
    }
    return '#E7F5EF';
  }

  private guardianOverviewText(): string {
    if (this.pendingDoseCount() > 0) {
      return '还有 ' + this.pendingDoseCount().toString() + ' 次服药未确认，建议先联系老人确认。';
    }
    if (this.currentHealthAlerts().length > 0) {
      return this.currentHealthAlerts()[0].title + ' ' + this.currentHealthAlerts()[0].value + (this.healthRetestRequested() ? '，已提醒老人复测，等待新数据。' : '，建议休息后复测。');
    }
    if (this.hasUnarrangedLowStockMedicine()) {
      return this.firstLowStockMedicineName() + '库存偏低，建议安排补药。';
    }
    return '今日服药和健康指标暂时平稳。';
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
    if (status === '稍后提醒') {
      return '稍后提醒';
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
    if (status === '稍后提醒') {
      return '#155EEF';
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

  private guardianConfirmMedication(): void {
    const record: MedicationRecord | undefined = confirmFirstPendingRecordByGuardian();
    if (record === undefined) {
      this.guardianLastCareLog = '刚刚查看：今日服药都已确认。';
      this.refreshToken++;
      promptAction.showToast({ message: '今日服药都已确认' });
      return;
    }
    this.guardianLastCareLog = '刚刚处理：已电话确认 ' + record.time + ' ' + record.medicineName + '。';
    addCareActionRecord('电话确认服药', record.time + ' ' + record.medicineName + '已由家属确认并补记。', '家属补记');
    this.refreshToken++;
    promptAction.showToast({ message: '已确认并补记服药' });
  }

  private guardianRequestHealthRetest(metricName: string): void {
    if (this.healthRetestRequested()) {
      promptAction.showToast({ message: '已提醒复测，等待新数据同步' });
      return;
    }
    markHealthRetestRequested();
    this.guardianLastCareLog = '刚刚处理：已提醒老人休息后复测' + metricName + '。';
    addCareActionRecord('提醒复测', '已提醒' + getCurrentElder().name + '休息后复测' + metricName + '。', '家属处理');
    this.refreshToken++;
    promptAction.showToast({ message: '已提醒老人复测' });
  }

  private isValidPhone(phone: string): boolean {
    if (phone.length !== 11 || phone.substring(0, 1) !== '1') {
      return false;
    }
    for (let index = 0; index < phone.length; index++) {
      const code: number = phone.charCodeAt(index);
      if (code < 48 || code > 57) {
        return false;
      }
    }
    return true;
  }

  private saveGuardianPhone(): void {
    if (!this.isValidPhone(this.guardianPhoneDraft)) {
      promptAction.showToast({ message: '请输入 11 位手机号' });
      return;
    }
    getCurrentUser().phone = this.guardianPhoneDraft;
    this.phoneEditVisible = false;
    this.refreshToken++;
    promptAction.showToast({ message: '手机号已更新' });
  }

  private elderNotifyFamily(reason: string): void {
    this.elderFamilyNotified = true;
    addCareActionRecord('老人求助', getCurrentElder().name + '已请求家属协助：' + reason, '老人端');
    this.refreshToken++;
    promptAction.showToast({ message: '已通知家属' });
  }

  private pendingDoseCount(): number {
    let count: number = 0;
    const records: MedicationRecord[] = this.currentTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status !== '已服用') {
        count++;
      }
    }
    return count;
  }

  private missedRecordCount(): number {
    let count: number = 0;
    const records: MedicationRecord[] = this.currentHistoryRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '漏服') {
        count++;
      }
    }
    return count;
  }

  private delayedRecordCount(): number {
    let count: number = 0;
    const records: MedicationRecord[] = this.currentHistoryRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '延迟服用') {
        count++;
      }
    }
    return count;
  }

  private confirmUnlinkElder(): void {
    const removedName: string = unlinkCurrentElder();
    this.guardianLastCareLog = '刚刚处理：已解绑' + removedName + '。';
    this.refreshToken++;
    promptAction.showToast({ message: '已解绑' + removedName });
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  private latestSyncText(): string {
    if (deviceStatus.connected) {
      return deviceStatus.lastSync;
    }
    return '今天 09:18';
  }

  private firstLowStockMedicineName(): string {
    return this.firstLowStockMedicine().name;
  }

  private firstLowStockMedicine(): Medicine {
    const list: Medicine[] = this.currentMedicines();
    for (let index = 0; index < list.length; index++) {
      if (list[index].stock <= list[index].threshold && !list[index].refillArranged) {
        return list[index];
      }
    }
    for (let index = 0; index < list.length; index++) {
      if (list[index].stock <= list[index].threshold) {
        return list[index];
      }
    }
    if (list.length > 0) {
      return list[0];
    }
    return {
      id: 0,
      elderId: 1,
      name: '暂无',
      spec: '',
      dosage: '',
      stock: 0,
      threshold: 0,
      note: '',
      photoUri: '',
      photoLabel: '药品',
      photoColor: '#E7F5EF',
      photoUploaded: false
    };
  }

  private hasUnarrangedLowStockMedicine(): boolean {
    const list: Medicine[] = this.currentMedicines();
    for (let index = 0; index < list.length; index++) {
      if (list[index].stock <= list[index].threshold && !list[index].refillArranged) {
        return true;
      }
    }
    return false;
  }

  private estimatedDays(item: Medicine): number {
    if (item.stock <= 0) {
      return 0;
    }
    return item.stock;
  }

  private planTimesForMedicine(name: string): string {
    const list: MedicationPlan[] = this.currentPlans();
    for (let index = 0; index < list.length; index++) {
      if (list[index].medicineName === name) {
        return list[index].times.join(' / ');
      }
    }
    return '未设置计划';
  }

  private planStatusForMedicine(name: string): string {
    const list: MedicationPlan[] = this.currentPlans();
    for (let index = 0; index < list.length; index++) {
      if (list[index].medicineName === name) {
        return list[index].enabled ? '计划启用' : '计划暂停';
      }
    }
    return '无计划';
  }

  private healthRangeText(type: string): string {
    if (type === 'heartRate') {
      return '参考范围 50-110 次/分';
    }
    if (type === 'bloodPressure') {
      return '建议结合医生目标范围';
    }
    return '空腹血糖需结合医嘱';
  }

  private shouldShowRecord(item: MedicationRecord): boolean {
    if (this.guardianRecordFilter === '全部') {
      return true;
    }
    return item.status === this.guardianRecordFilter;
  }

  private recordDateText(item: MedicationRecord): string {
    const splitIndex: number = item.time.indexOf(' ');
    if (splitIndex > 0) {
      return item.time.substring(0, splitIndex);
    }
    return '今天';
  }

  private recordClockText(item: MedicationRecord): string {
    const splitIndex: number = item.time.indexOf(' ');
    if (splitIndex > 0 && splitIndex + 1 < item.time.length) {
      return item.time.substring(splitIndex + 1);
    }
    return item.time;
  }

  private visibleHistoryDates(): string[] {
    const dates: string[] = [];
    const records: MedicationRecord[] = this.currentHistoryRecords();
    for (let index = 0; index < records.length; index++) {
      if (this.shouldShowRecord(records[index])) {
        const dateText: string = this.recordDateText(records[index]);
        let exists: boolean = false;
        for (let dateIndex = 0; dateIndex < dates.length; dateIndex++) {
          if (dates[dateIndex] === dateText) {
            exists = true;
            break;
          }
        }
        if (!exists) {
          dates.push(dateText);
        }
      }
    }
    return dates;
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
      .tabBar(this.NavItem('服药', '追踪', 3))

      TabContent() {
        this.GuardianSettingTab()
      }
      .tabBar(this.NavItem('我的', '看护', 4))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .animationDuration(180)
    .backgroundColor('#EEF3F7')
    .onChange((index: number) => {
      this.currentTab = index;
    })
  }

  @Builder ElderTodayTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('安心服药助手')
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
        ForEach(this.currentTodayRecords(), (item: MedicationRecord) => {
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
        this.HeaderBlock('药品管理')
        this.LowStockNotice()
        Row({ space: 10 }) {
          this.ActionButton('添加药品', 'pages/AddMedicinePage')
        }
        .width('100%')
        Row({ space: 8 }) {
          this.QuickEntry('药品管理', '库存/详情', 'pages/MedicineLibraryPage')
          this.QuickEntry('用药计划', '时间表', 'pages/PlanListPage')
          this.QuickEntry('补记服药', '漏记时', 'pages/CheckInPage')
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('看不懂药？点这里求助')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('可以拍照、说话，或直接叫家属帮你看。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#52635F')
          Button('打开问药求助')
            .width('100%')
            .height(56)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
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
        ForEach(this.currentPlans(), (plan: MedicationPlan) => {
          this.PlanRow(plan)
        }, (plan: MedicationPlan) => plan.id.toString())

        this.SectionTitle('常用药品')
        ForEach(this.currentMedicines(), (item: Medicine) => {
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
        this.HeaderBlock('健康监测')
        this.DeviceCard()
        this.AlertCard()
        this.HealthActionCard()
        this.SectionTitle('最近指标')
        ForEach(this.currentHealthMetrics(), (item: HealthMetric) => {
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
        this.HeaderBlock('我的')
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

        this.ElderInlineSettingRow('字大一点', '看不清字时打开，页面文字会更醒目。', this.elderLargeTextEnabled(), '已打开', '打开', () => {
          const nextValue: boolean = !this.elderLargeTextEnabled();
          setLargeTextMode(nextValue);
          this.refreshToken++;
          promptAction.showToast({ message: nextValue ? '已打开大字模式' : '已关闭大字模式' });
        })
        this.ElderInlineSettingRow('提醒响一点', '容易忘记吃药时打开，提醒会更明显。', this.elderStrongReminderEnabled(), '已打开', '打开', () => {
          const nextValue: boolean = !this.elderStrongReminderEnabled();
          setStrongReminderMode(nextValue);
          this.refreshToken++;
          promptAction.showToast({ message: nextValue ? '已打开强提醒' : '已关闭强提醒' });
        })
        this.ElderContactFamilyRow()
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
      Column({ space: 14 }) {
        this.GuardianDashboardHeader()
        this.GuardianMedicationOverviewCard()
        this.GuardianHealthOverviewCard()
        this.GuardianCareLogCard()
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianMedicineTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('药品代管')
        this.InventoryRiskCard()
        Row({ space: 12 }) {
          this.ActionButton('添加/识别药品', 'pages/AddMedicinePage')
          this.ActionButton('新增用药计划', 'pages/AddPlanPage')
        }
        .width('100%')

        this.SectionTitle('库存预警药品')
        ForEach(this.currentMedicines(), (item: Medicine) => {
          if (item.stock <= item.threshold) {
            this.GuardianMedicineRow(item)
          }
        }, (item: Medicine) => 'risk' + item.id.toString() + item.stock.toString())

        this.SectionTitle('全部药品')
        ForEach(this.currentMedicines(), (item: Medicine) => {
          this.GuardianMedicineRow(item)
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
        this.HeaderBlock('健康趋势')
        this.GuardianDeviceCard()
        this.GuardianAlertTraceCard()
        this.GuardianHealthActionCard()
        this.SectionTitle('指标透明数据')
        this.HealthTrendCard()
        ForEach(this.currentHealthMetrics(), (item: HealthMetric) => {
          this.GuardianHealthRow(item)
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
        this.HeaderBlock('服药追踪')
        this.SectionTitle('今日服药时间线')
        ForEach(this.currentTodayRecords(), (item: MedicationRecord) => {
          this.GuardianDoseTimelineRow(item)
        }, (item: MedicationRecord) => item.time + item.medicineName + item.status + this.refreshToken.toString())
        Row({ space: 8 }) {
          this.FilterChip('全部')
          this.FilterChip('已服用')
          this.FilterChip('漏服')
          this.FilterChip('延迟服用')
        }
        .width('100%')
        this.SectionTitle('历史记录（按日期）')
        ForEach(this.visibleHistoryDates(), (dateText: string) => {
          this.HistoryDateGroup(dateText)
        }, (dateText: string) => dateText + this.guardianRecordFilter + this.refreshToken.toString())
      }
      .padding({ left: 18, right: 18, top: 18, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder GuardianSettingTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderBlock('我的看护')
        this.BindingManagementCard()
        this.SectionTitle('通知管理')
        ForEach(notificationPreferences, (item: NotificationPreference) => {
          this.NotificationPreferenceRow(item)
        }, (item: NotificationPreference) => item.title + item.enabled.toString() + this.refreshToken.toString())

        this.EscalationRuleCard()
        this.ModifyPhoneCard()
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
        Text(this.currentHealthAlerts().length > 0 ? '需要关注' : '状态平稳')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentHealthAlerts().length > 0 ? '#B42318' : '#0B7A5B')
        Blank()
        Text(this.currentHealthAlerts().length > 0 ? '已通知' : '正常')
          .fontSize(14)
          .fontColor(this.currentHealthAlerts().length > 0 ? '#B42318' : '#0B7A5B')
      }
      .width('100%')
      Text(this.currentHealthAlerts().length > 0 ? this.currentHealthAlerts()[0].title + '：' + this.currentHealthAlerts()[0].value + '，建议稍后复测或联系家属。' : '今天暂未发现心率、血压或血糖异常。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(this.currentHealthAlerts().length > 0 ? '#FFF1F0' : '#E7F5EF')
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
      Row({ space: 14 }) {
        this.MedicinePhoto(this.nextDoseRecord().medicineName, 88)
        Column({ space: 5 }) {
          Text(this.nextDoseRecord().time)
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0B7A5B')
          Text(this.nextDoseRecord().medicineName)
            .fontSize(23)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
            .maxLines(2)
          Text(isMedicinePhotoUploaded(this.nextDoseRecord().medicineName) ? '看图片核对药盒后再服用' : '可上传药盒照片，方便以后辨认')
            .fontSize(14)
            .fontColor('#667085')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
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
          .onClick(() => {
            selectReminder(this.nextDoseRecord());
            router.pushUrl({ url: 'pages/ReminderDetailPage' });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder MedicinePhoto(name: string, size: number) {
    Stack() {
      if (getMedicinePhotoUri(name) !== '') {
        Image(getMedicinePhotoUri(name))
          .width(size)
          .height(size)
          .borderRadius(size >= 70 ? 22 : 16)
          .objectFit(ImageFit.Cover)
      } else {
        Column({ space: 3 }) {
          Text(getMedicinePhotoLabel(name))
            .fontSize(size >= 80 ? 18 : 14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#102A27')
            .maxLines(1)
          Text(isMedicinePhotoUploaded(name) ? '药图' : '待传')
            .fontSize(size >= 70 ? 11 : 9)
            .fontColor('#0B7A5B')
        }
        .width(size)
        .height(size)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width(size)
    .height(size)
    .borderRadius(size >= 70 ? 22 : 16)
    .backgroundColor(getMedicinePhotoColor(name))
    .border({ width: 2, color: '#FFFFFF' })
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
      Text(this.currentHealthAlerts().length > 0 ? '异常处理建议' : '健康记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentHealthAlerts().length > 0 ? '#B42318' : '#14213D')
      Text(this.currentHealthAlerts().length > 0 ? '心率偏高时先坐下休息，几分钟后复测一次；如果仍不舒服，及时联系家属。' : '没有异常时，定期记录血压、血糖和心率即可。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button(this.currentHealthAlerts().length > 0 ? '复测一次' : '记录指标')
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
          .onClick(() => this.elderNotifyFamily('健康不适或看不懂用药'))
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder GuardianDashboardHeader() {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 5 }) {
          Text(getCurrentElder().name + '看护')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#102A27')
          Text('重点查看今日服药、手环健康和最近处置。')
            .fontSize(15)
            .lineHeight(22)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.SmallBadge('家属端', '#155EEF', '#EAF2FF')
      }
      .width('100%')
      this.SingleBoundElderCard()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SingleBoundElderCard() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text('已绑定：' + getCurrentElder().name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text(this.guardianOverviewStatus())
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.guardianOverviewColor())
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
          .backgroundColor('#FFFFFF')
      }
      .width('100%')
      Text(this.guardianOverviewText())
        .fontSize(14)
        .lineHeight(21)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor(this.guardianOverviewBgColor())
    .border({ width: 1, color: this.guardianOverviewColor() })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder GuardianMedicationOverviewCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 5 }) {
          Text('今日服药监督')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('完成 ' + this.completionText() + '，还有 ' + this.pendingDoseCount().toString() + ' 次需要确认')
            .fontSize(15)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.SmallBadge(this.adherencePercent().toString() + '%', this.pendingDoseCount() > 0 ? '#D97706' : '#0B7A5B', this.pendingDoseCount() > 0 ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
      Progress({ value: this.adherencePercent(), total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(this.pendingDoseCount() > 0 ? '#D97706' : '#0B7A5B')
      this.GuardianPriorityDosePanel()
      ForEach(this.currentTodayRecords(), (item: MedicationRecord) => {
        this.GuardianDoseTimelineRow(item)
      }, (item: MedicationRecord) => item.time + item.medicineName + item.status + this.refreshToken.toString())
      Row({ space: 10 }) {
        Button(this.pendingDoseCount() > 0 ? '联系老人确认' : '已全部确认')
          .layoutWeight(1)
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .backgroundColor('#0B7A5B')
          .onClick(() => {
            this.guardianConfirmMedication();
          })
        Button('查看完整记录')
          .layoutWeight(1)
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .fontColor('#155EEF')
          .backgroundColor('#EAF2FF')
          .onClick(() => {
            this.currentTab = 3;
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder GuardianPriorityDosePanel() {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.pendingDoseCount() > 0 ? '优先确认' : '今日完成')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.pendingDoseCount() > 0 ? '#D97706' : '#0B7A5B')
        Text(this.pendingDoseCount() > 0 ? this.nextDoseRecord().time + '  ' + this.nextDoseRecord().medicineName : '所有服药记录已确认')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
          .maxLines(1)
        Text(this.pendingDoseCount() > 0 ? '来源：' + (this.nextDoseRecord().source === undefined ? '系统未响应' : this.nextDoseRecord().source) : '来源：老人端确认记录')
          .fontSize(13)
          .fontColor('#667085')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      this.SmallBadge(this.statusLabel(this.nextDoseRecord().status), this.statusColor(this.nextDoseRecord().status), this.pendingDoseCount() > 0 ? '#FFF7E8' : '#E7F5EF')
    }
    .width('100%')
    .padding(14)
    .borderRadius(18)
    .backgroundColor(this.pendingDoseCount() > 0 ? '#FFF7E8' : '#E7F5EF')
  }

  @Builder GuardianHealthOverviewCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 5 }) {
          Text('手环健康监测')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('最近同步：' + this.latestSyncText())
            .fontSize(15)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.SmallBadge(this.currentHealthAlerts().length > 0 ? (this.healthRetestRequested() ? '已提醒复测' : '需复测') : '平稳', this.currentHealthAlerts().length > 0 ? (this.healthRetestRequested() ? '#155EEF' : '#B42318') : '#0B7A5B', this.currentHealthAlerts().length > 0 ? (this.healthRetestRequested() ? '#EAF2FF' : '#FFF1F0') : '#E7F5EF')
      }
      .width('100%')
      Row({ space: 10 }) {
        this.HealthSignalCard('心率', this.latestMetricValue('heartRate'), this.latestMetricTime('heartRate'), this.latestHeartRateNormal() ? '#0B7A5B' : '#B42318')
        this.HealthSignalCard('血压', this.latestMetricValue('bloodPressure'), this.latestMetricTime('bloodPressure'), '#0B7A5B')
        this.HealthSignalCard('血糖', this.latestMetricValue('bloodSugar'), this.latestMetricTime('bloodSugar'), '#0B7A5B')
      }
      .width('100%')
      Text('数据来源：' + deviceStatus.name + '，同步时间 ' + this.latestSyncText())
        .fontSize(13)
        .fontColor('#667085')
        .width('100%')
      if (this.currentHealthAlerts().length > 0) {
        Text(this.currentHealthAlerts()[0].title + '：' + this.currentHealthAlerts()[0].value + (this.healthRetestRequested() ? '，已提醒老人复测，等待手环同步新结果。' : '，建议先休息后复测，持续异常再就医。'))
          .fontSize(15)
          .lineHeight(23)
          .fontColor('#B42318')
          .width('100%')
          .padding(12)
          .borderRadius(16)
          .backgroundColor('#FFF1F0')
      }
      Row({ space: 10 }) {
        Button(this.healthRetestRequested() ? '已提醒复测' : '提醒复测')
          .layoutWeight(1)
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .backgroundColor('#0B7A5B')
          .onClick(() => {
            this.guardianRequestHealthRetest('健康指标');
          })
        Button('查看健康趋势')
          .layoutWeight(1)
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .fontColor('#155EEF')
          .backgroundColor('#EAF2FF')
          .onClick(() => {
            this.currentTab = 2;
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder HealthSignalCard(title: string, value: string, time: string, color: string) {
    Column({ space: 5 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#52635F')
        .maxLines(1)
      Text(value)
        .fontSize(value.length > 8 ? 14 : 17)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .width('100%')
        .maxLines(1)
        .textAlign(TextAlign.Center)
      Text(time)
        .fontSize(12)
        .fontColor('#98A2B3')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(92)
    .padding(10)
    .borderRadius(18)
    .backgroundColor('#F6F8FB')
    .justifyContent(FlexAlign.Center)
  }

  @Builder GuardianCareLogCard() {
    Column({ space: 10 }) {
      Row() {
        Text('今日处置记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text('最新')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#155EEF')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
          .backgroundColor('#EAF2FF')
      }
      .width('100%')
      Text(this.guardianLastCareLog)
        .fontSize(15)
        .lineHeight(23)
        .fontColor('#52635F')
      ForEach(this.currentCareActions(), (item: CareActionRecord) => {
        this.CareHistoryRow(item.time + '  ' + item.title, item.desc + '｜来源：' + item.source)
      }, (item: CareActionRecord) => item.time + item.title + item.desc + this.refreshToken.toString())
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder CareHistoryRow(title: string, desc: string) {
    Row({ space: 10 }) {
      Text('')
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor('#0B7A5B')
      Column({ space: 3 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(desc)
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#52635F')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder GuardianDoseTimelineRow(item: MedicationRecord) {
    Row({ space: 12 }) {
      this.MedicinePhoto(item.medicineName, 50)
      Column({ space: 2 }) {
        Text(item.time)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.status === '已服用' ? '已同步' : '待确认')
          .fontSize(12)
          .fontColor('#667085')
      }
      .width(72)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 5 }) {
        Text(item.medicineName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text((item.status === '已服用' ? '老人端已确认，家属无需处理。' : '建议电话确认是否已经服用。') + ' 来源：' + (item.source === undefined ? '系统未响应' : item.source))
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#52635F')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      this.SmallBadge(this.statusLabel(item.status), this.statusColor(item.status), item.status === '已服用' ? '#E7F5EF' : '#FFF7E8')
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      selectReminder(item);
      router.pushUrl({ url: 'pages/ReminderDetailPage' });
    })
  }

  @Builder InventoryRiskCard() {
    Column({ space: 12 }) {
      Row() {
        Text('库存风险概览')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        this.SmallBadge(this.lowStockText(), this.lowStockCount() > 0 ? '#B54708' : '#0B7A5B', this.lowStockCount() > 0 ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
      Text(this.lowStockCount() > 0 ? this.firstLowStockMedicineName() + '低于库存阈值，预计还能使用约 6 天。建议尽快补药或确认是否还有备用药。' : '当前常用药库存充足。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Progress({ value: this.lowStockCount() > 0 ? 70 : 20, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(this.lowStockCount() > 0 ? '#D97706' : '#0B7A5B')
      if (this.lowStockCount() > 0) {
        Button(this.firstLowStockMedicine().refillArranged ? '已安排补药' : '安排补药')
          .width('100%')
          .height(46)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .backgroundColor(this.firstLowStockMedicine().refillArranged ? '#98A2B3' : '#0B7A5B')
          .onClick(() => {
            if (this.firstLowStockMedicine().refillArranged) {
              promptAction.showToast({ message: '这项补药已经安排过了' });
              return;
            }
            addRefillTodo(this.firstLowStockMedicineName());
            addCareActionRecord('安排补药', this.firstLowStockMedicineName() + '库存不足，已记录补药安排。', '家属处理');
            this.guardianLastCareLog = '刚刚处理：已为' + this.firstLowStockMedicineName() + '安排补药。';
            this.refreshToken++;
            promptAction.showToast({ message: '已安排补药' });
          })
      }
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(this.lowStockCount() > 0 ? '#FFF7E8' : '#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder GuardianMedicineRow(item: Medicine) {
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        this.MedicinePhoto(item.name, 58)
        Column({ space: 5 }) {
          Text(item.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
            .maxLines(1)
          Text(item.spec + '  默认 ' + item.dosage + '  ' + this.planTimesForMedicine(item.name))
            .fontSize(15)
            .lineHeight(21)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.SmallBadge(item.stock <= item.threshold ? (item.refillArranged ? '已安排补药' : '待补药') : '库存正常', item.stock <= item.threshold ? '#B54708' : '#0B7A5B', item.stock <= item.threshold ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
      Row({ space: 8 }) {
        this.DataPill('库存 ' + item.stock.toString())
        this.DataPill('阈值 ' + item.threshold.toString())
        this.DataPill('约 ' + this.estimatedDays(item).toString() + ' 天')
      }
      .width('100%')
      Text(this.planStatusForMedicine(item.name) + '；' + item.note)
        .fontSize(14)
        .lineHeight(21)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      selectMedicine(item.name);
      router.pushUrl({ url: 'pages/MedicineDetailPage' });
    })
  }

  @Builder GuardianDeviceCard() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 5 }) {
          Text(deviceStatus.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('最近同步：' + this.latestSyncText())
            .fontSize(16)
            .fontColor('#52635F')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        this.SmallBadge(deviceStatus.battery.toString() + '%', '#0B7A5B', '#E7F5EF')
      }
      .width('100%')
      Text(deviceStatus.connected ? '设备在线，健康数据会持续同步。' : '最近一条异常来自今天 09:18，建议确认设备同步状态。')
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

  @Builder GuardianAlertTraceCard() {
    Column({ space: 10 }) {
      Text('异常追踪')
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentHealthAlerts().length > 0 ? '#B42318' : '#0B7A5B')
      Text(this.currentHealthAlerts().length > 0 ? this.currentHealthAlerts()[0].title + '：' + this.currentHealthAlerts()[0].value + '，来源于' + this.currentHealthAlerts()[0].time + '手环同步。' : '当前没有异常提醒。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Text(this.currentHealthAlerts().length > 0 ? '建议动作：联系老人确认状态，休息后复测；如持续不适及时就医。' : '建议动作：保持每日记录。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor(this.currentHealthAlerts().length > 0 ? '#B42318' : '#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(this.currentHealthAlerts().length > 0 ? '#FFF1F0' : '#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder GuardianHealthActionCard() {
    Column({ space: 12 }) {
      Text('复测与跟进')
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(this.currentHealthAlerts().length > 0 ? '建议先提醒老人休息后复测。若复测仍偏高，再联系老人并就医咨询。' : '当前没有健康异常，保持手环佩戴和每日同步即可。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button(this.guardianHealthContacted ? '已联系老人' : '一键联系老人')
          .layoutWeight(1)
          .height(52)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .backgroundColor('#0B7A5B')
          .onClick(() => {
            this.guardianHealthContacted = true;
            this.guardianLastCareLog = '刚刚处理：已联系老人确认健康状态，等待复测结果。';
            addCareActionRecord('联系老人', '已联系' + getCurrentElder().name + '确认健康状态，等待复测结果。', '家属处理');
            this.refreshToken++;
            promptAction.showToast({ message: '已记录联系老人' });
          })
        Button(this.healthRetestRequested() ? '已提醒复测' : '提醒复测')
          .layoutWeight(1)
          .height(52)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .fontColor('#155EEF')
          .backgroundColor('#EAF2FF')
          .onClick(() => {
            this.guardianRequestHealthRetest('心率');
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder HealthTrendCard() {
    Column({ space: 12 }) {
      Row() {
        Text('最近 7 天趋势')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        this.SmallBadge(this.currentHealthAlerts().length > 0 ? '偶发异常' : '整体平稳', this.currentHealthAlerts().length > 0 ? '#B54708' : '#0B7A5B', this.currentHealthAlerts().length > 0 ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
      this.TrendRow('心率', this.currentHealthAlerts().length > 0 ? 72 : 42, this.latestHeartRateText(), this.currentHealthAlerts().length > 0 ? '#D97706' : '#0B7A5B')
      this.TrendRow('血压', 48, '近 7 天平稳', '#0B7A5B')
      this.TrendRow('血糖', 40, '早餐前波动小', '#155EEF')
      Text(this.currentHealthAlerts().length > 0 ? '说明：当前为单次异常，建议复测后再判断是否持续。' : '说明：最近指标没有明显异常，继续保持日常记录。')
        .fontSize(14)
        .lineHeight(21)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder TrendRow(label: string, value: number, desc: string, color: string) {
    Column({ space: 6 }) {
      Row() {
        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text(desc)
          .fontSize(13)
          .fontColor('#667085')
      }
      .width('100%')
      Progress({ value: value, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(color)
    }
    .width('100%')
  }

  @Builder CareStepBadge(index: string, text: string) {
    Row({ space: 6 }) {
      Text(index)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(22)
        .height(22)
        .textAlign(TextAlign.Center)
        .borderRadius(11)
        .backgroundColor('#0B7A5B')
      Text(text)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(40)
    .padding({ left: 8, right: 8 })
    .borderRadius(14)
    .backgroundColor('#F6FEF9')
  }

  @Builder GuardianHealthRow(item: HealthMetric) {
    Column({ space: 8 }) {
      Row() {
        Text(item.name)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        this.SmallBadge(item.normal ? '正常' : '建议复测', item.normal ? '#0B7A5B' : '#B42318', item.normal ? '#E7F5EF' : '#FFF1F0')
      }
      .width('100%')
      Row() {
        Text(item.time + '  ' + this.healthRangeText(item.type))
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#667085')
          .layoutWeight(1)
          .maxLines(2)
        Text(item.value)
          .fontSize(item.type === 'bloodPressure' ? 15 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.normal ? '#0B7A5B' : '#B42318')
          .maxLines(1)
          .textAlign(TextAlign.End)
          .width(118)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(item.normal ? '#FFFFFF' : '#FFF1F0')
  }

  @Builder FilterChip(label: string) {
    Text(label)
      .fontSize(15)
      .fontWeight(this.guardianRecordFilter === label ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.guardianRecordFilter === label ? '#0B7A5B' : '#52635F')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(42)
      .borderRadius(16)
      .backgroundColor(this.guardianRecordFilter === label ? '#E7F5EF' : '#FFFFFF')
      .onClick(() => {
        this.guardianRecordFilter = label;
      })
  }

  @Builder NotificationPreferenceRow(item: NotificationPreference) {
    Row() {
      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.desc)
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#667085')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Toggle({ type: ToggleType.Switch, isOn: item.enabled })
        .onChange((value: boolean) => {
          setNotificationPreference(item.title, value);
          this.refreshToken++;
        })
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
  }

  @Builder BindingManagementCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 5 }) {
          Text('绑定老人')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text(getCurrentElder().name + '  ·  ' + getCurrentElder().relation + '  ·  已绑定')
            .fontSize(15)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('正常')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0B7A5B')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(14)
          .backgroundColor('#E7F5EF')
      }
      .width('100%')
      this.PermissionLine('数据范围', '药品、计划、服药记录、健康告警和库存风险')
      Row({ space: 10 }) {
        Button(this.authorizationVisible ? '收起授权' : '查看授权')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .borderRadius(16)
          .fontColor('#155EEF')
          .backgroundColor('#EAF2FF')
          .onClick(() => {
            this.authorizationVisible = !this.authorizationVisible;
          })
        Button('解绑老人')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .borderRadius(16)
          .fontColor('#B42318')
          .backgroundColor('#FFF1F0')
          .onClick(() => {
            this.unlinkConfirmVisible = true;
          })
      }
      .width('100%')
      if (this.authorizationVisible) {
        this.AuthorizationDetailPanel()
      }
      if (this.unlinkConfirmVisible) {
        Column({ space: 10 }) {
          Text('确认解绑' + getCurrentElder().name + '？')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#B42318')
          Text('解绑后，当前账号将不能继续查看该老人的用药、健康和记录。')
            .fontSize(14)
            .lineHeight(21)
            .fontColor('#52635F')
          Row({ space: 10 }) {
            Button('取消')
              .layoutWeight(1)
              .height(42)
              .fontSize(15)
              .borderRadius(15)
              .fontColor('#52635F')
              .backgroundColor('#F2F4F7')
              .onClick(() => {
                this.unlinkConfirmVisible = false;
              })
            Button('确认解绑')
              .layoutWeight(1)
              .height(42)
              .fontSize(15)
              .borderRadius(15)
              .fontColor('#FFFFFF')
              .backgroundColor('#B42318')
              .onClick(() => {
                this.unlinkConfirmVisible = false;
                this.confirmUnlinkElder();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(14)
        .borderRadius(16)
        .backgroundColor('#FFF1F0')
      }
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder EscalationRuleCard() {
    Row() {
      Column({ space: 5 }) {
        Text('异常升级提醒')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(this.guardianEscalationEnabled ? '连续漏服、心率持续异常或长时间未响应时，会提升为紧急提醒。' : '关闭后，只保留普通通知。')
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#667085')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Toggle({ type: ToggleType.Switch, isOn: this.guardianEscalationEnabled })
        .onChange((value: boolean) => {
          this.guardianEscalationEnabled = value;
        })
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
  }

  @Builder AuthorizationDetailPanel() {
    Column({ space: 10 }) {
      this.PermissionLine('授权状态', '老人已授权当前家属账号进行看护')
      this.PermissionLine('共享范围', '仅同步用药、健康告警、库存风险和处置记录')
      this.PermissionLine('隐私说明', '健康数据只用于看护提醒，不对外共享')
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor('#F6F8FB')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ModifyPhoneCard() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Column({ space: 5 }) {
          Text('手机号')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text(getCurrentUser().phone)
            .fontSize(15)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Button(this.phoneEditVisible ? '取消' : '修改手机号')
          .width(120)
          .height(44)
          .fontSize(16)
          .borderRadius(16)
          .fontColor(this.phoneEditVisible ? '#52635F' : '#155EEF')
          .backgroundColor(this.phoneEditVisible ? '#F2F4F7' : '#EAF2FF')
          .onClick(() => {
            this.phoneEditVisible = !this.phoneEditVisible;
            this.guardianPhoneDraft = getCurrentUser().phone;
          })
      }
      .width('100%')
      if (this.phoneEditVisible) {
        Column({ space: 10 }) {
          TextInput({ placeholder: '请输入新手机号', text: this.guardianPhoneDraft })
            .height(48)
            .fontSize(16)
            .borderRadius(16)
            .backgroundColor('#F6F8FB')
            .onChange((value: string) => {
              this.guardianPhoneDraft = value;
            })
          Button('保存手机号')
            .width('100%')
            .height(44)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .borderRadius(16)
            .backgroundColor('#0B7A5B')
            .onClick(() => this.saveGuardianPhone())
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PermissionLine(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
        .width(76)
      Text(value)
        .fontSize(14)
        .lineHeight(21)
        .fontColor('#52635F')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 9, bottom: 9 })
    .borderRadius(14)
    .backgroundColor('#F6F8FB')
  }

  @Builder PermissionStatusPill(text: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor('#0B7A5B')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(34)
      .borderRadius(13)
      .backgroundColor('#E7F5EF')
  }

  @Builder DataPill(text: string) {
    Text(text)
      .fontSize(13)
      .fontColor('#52635F')
      .padding({ left: 9, right: 9, top: 5, bottom: 5 })
      .borderRadius(12)
      .backgroundColor('#F2F4F7')
  }

  @Builder DeviceCard() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(deviceStatus.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text(deviceStatus.connected ? '已连接，' + deviceStatus.lastSync : '未连接，请打开手环并靠近手机')
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

  @Builder HeaderBlock(title: string) {
    Column({ space: 0 }) {
      Text(title)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
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
      .onClick(() => {
        if (url === 'pages/AddPlanPage') {
          startCreatePlan();
        }
        router.pushUrl({ url: url });
      })
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
    Row({ space: 12 }) {
      this.MedicinePhoto(item.medicineName, 58)
      Column({ space: 5 }) {
        Text(item.time)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.medicineName)
          .fontSize(17)
          .maxLines(1)
          .fontColor('#52635F')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      this.SmallBadge(this.statusLabel(item.status), this.statusColor(item.status), item.status === '已服用' ? '#E7F5EF' : '#FFF7E8')
    }
    .width('100%')
    .padding(18)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
  }

  @Builder MedicineRow(item: Medicine) {
    Column({ space: 8 }) {
      Row({ space: 12 }) {
        this.MedicinePhoto(item.name, 64)
        Column({ space: 5 }) {
          Text(item.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
            .maxLines(1)
          Text(item.spec + '  默认 ' + item.dosage)
            .fontSize(16)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.SmallBadge(item.stock <= item.threshold ? '快吃完' : '充足', item.stock <= item.threshold ? '#B54708' : '#0B7A5B', item.stock <= item.threshold ? '#FFF7E8' : '#E7F5EF')
      }
      .width('100%')
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
    .onClick(() => {
      selectMedicine(item.name);
      router.pushUrl({ url: 'pages/MedicineDetailPage' });
    })
  }

  @Builder PlanRow(plan: MedicationPlan) {
    Column({ space: 8 }) {
      Row({ space: 12 }) {
        this.MedicinePhoto(plan.medicineName, 64)
        Column({ space: 4 }) {
          Text(plan.medicineName)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
            .maxLines(1)
          Text(plan.dosage + '  ' + plan.mealTime)
            .fontSize(16)
            .fontColor('#52635F')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.SmallBadge(plan.enabled ? '启用' : '暂停', plan.enabled ? '#0B7A5B' : '#667085', plan.enabled ? '#E7F5EF' : '#F2F4F7')
      }
      .width('100%')
      Text(plan.times.join(' / '))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0B7A5B')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      selectPlan(plan.id);
      router.pushUrl({ url: 'pages/PlanDetailPage' });
    })
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
        Text('来源：' + (item.source === undefined ? '系统未响应' : item.source))
          .fontSize(13)
          .fontColor('#667085')
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

  @Builder HistoryDateGroup(dateText: string) {
    Column({ space: 12 }) {
      Row() {
        Text(dateText)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text('按时间查看')
          .fontSize(13)
          .fontColor('#667085')
      }
      .width('100%')
      ForEach(this.currentHistoryRecords(), (item: MedicationRecord) => {
        if (this.shouldShowRecord(item) && this.recordDateText(item) === dateText) {
          this.HistoryRecordLine(item)
        }
      }, (item: MedicationRecord) => item.time + item.medicineName + item.status + this.guardianRecordFilter)
    }
    .width('100%')
    .padding(16)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
  }

  @Builder HistoryRecordLine(item: MedicationRecord) {
    Row({ space: 12 }) {
      Text(this.recordClockText(item))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
        .width(58)
      Column({ space: 3 }) {
        Text(item.medicineName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
          .maxLines(1)
        Text('来源：' + (item.source === undefined ? '系统未响应' : item.source))
          .fontSize(13)
          .fontColor('#667085')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      this.SmallBadge(this.statusLabel(item.status), this.statusColor(item.status), item.status === '漏服' ? '#FFF1F0' : item.status === '延迟服用' ? '#FFF7E8' : '#E7F5EF')
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
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

  @Builder ElderInlineSettingRow(title: string, desc: string, enabled: boolean, enabledText: string, disabledText: string, action: () => void) {
    Row() {
      Column({ space: 5 }) {
        Text(title)
          .fontSize(this.elderLargeTextEnabled() ? 24 : 21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(desc)
          .fontSize(this.elderLargeTextEnabled() ? 18 : 16)
          .lineHeight(this.elderLargeTextEnabled() ? 26 : 23)
          .fontColor('#52635F')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button(enabled ? enabledText : disabledText)
        .height(42)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .borderRadius(16)
        .fontColor(enabled ? '#0B7A5B' : '#52635F')
        .backgroundColor(enabled ? '#E7F5EF' : '#F2F4F7')
        .onClick(() => action())
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
  }

  @Builder ElderContactFamilyRow() {
    Row() {
      Column({ space: 5 }) {
        Text('联系家属')
          .fontSize(this.elderLargeTextEnabled() ? 24 : 21)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(this.elderFamilyNotified ? '已经提醒家属，请等待家属联系。' : '身体不舒服或不懂用药时，点一下叫家属帮忙。')
          .fontSize(this.elderLargeTextEnabled() ? 18 : 16)
          .lineHeight(this.elderLargeTextEnabled() ? 26 : 23)
          .fontColor('#52635F')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button(this.elderFamilyNotified ? '已提醒' : '提醒家属')
        .height(42)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => {
          this.elderFamilyNotified = true;
          addCareActionRecord('老人求助', getCurrentElder().name + '在老人端请求家属协助。', '老人端');
          this.refreshToken++;
          promptAction.showToast({ message: '已提醒家属' });
        })
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
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
