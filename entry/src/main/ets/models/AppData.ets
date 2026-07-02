export type UserRole = 'elder' | 'guardian';
export type HealthMetricType = 'heartRate' | 'bloodPressure' | 'bloodSugar';
export type RecordSource = '老人确认' | '家属补记' | '设备同步' | '系统未响应';
export type PlanFormMode = 'create' | 'edit';

export interface ElderProfile {
  id: number;
  name: string;
  relation: string;
  bindCode: string;
  contact: string;
  status: string;
}

export interface UserProfile {
  id: number;
  name: string;
  phone: string;
  role: UserRole;
  relation?: string;
  elderId?: number;
}

export interface FamilyBinding {
  elderId: number;
  guardianId: number;
  code: string;
  relation: string;
}

export interface ElderPreference {
  elderId: number;
  largeText: boolean;
  strongReminder: boolean;
}

export interface Session {
  userId: number;
  role: UserRole;
}

export interface Medicine {
  id: number;
  elderId: number;
  name: string;
  spec: string;
  dosage: string;
  stock: number;
  threshold: number;
  note: string;
  photoUri: string;
  photoLabel: string;
  photoColor: string;
  photoUploaded: boolean;
  refillArranged?: boolean;
}

export interface MedicationPlan {
  id: number;
  elderId: number;
  medicineName: string;
  times: string[];
  dosage: string;
  mealTime: string;
  enabled: boolean;
}

export interface MedicationRecord {
  elderId: number;
  time: string;
  medicineName: string;
  status: string;
  source?: RecordSource;
}

export interface HealthMetric {
  elderId: number;
  type: HealthMetricType;
  name: string;
  value: string;
  numericValue: number;
  unit: string;
  time: string;
  normal: boolean;
}

export interface HealthAlert {
  elderId: number;
  type: HealthMetricType;
  title: string;
  value: string;
  time: string;
  notified: boolean;
  retestRequested?: boolean;
  resolved?: boolean;
}

export interface DeviceStatus {
  elderId: number;
  name: string;
  connected: boolean;
  battery: number;
  lastSync: string;
}

export interface MenuItem {
  title: string;
  desc: string;
  url: string;
}

export interface CareActionRecord {
  elderId: number;
  time: string;
  title: string;
  desc: string;
  source: string;
}

export interface StockUpdateResult {
  found: boolean;
  lowStock: boolean;
  refillCleared: boolean;
}

export interface NotificationPreference {
  title: string;
  desc: string;
  enabled: boolean;
}

export const users: UserProfile[] = [
  { id: 1, name: '张阿姨', phone: '13800000001', role: 'elder', elderId: 1 },
  { id: 2, name: '李女士', phone: '13800000002', role: 'guardian', relation: '女儿' }
];

export const familyBindings: FamilyBinding[] = [
  { elderId: 1, guardianId: 2, code: 'AX2026', relation: '女儿' }
];

export const elderPreferences: ElderPreference[] = [
  { elderId: 1, largeText: false, strongReminder: true }
];

export const elderProfiles: ElderProfile[] = [
  { id: 1, name: '张阿姨', relation: '母亲', bindCode: 'AX2026', contact: '女儿 李女士 13800000002', status: '需关注' }
];

export const currentSession: Session = {
  userId: 1,
  role: 'elder'
};

export let selectedMedicineName: string = '二甲双胍片';
export let selectedElderId: number = 1;
export let selectedPlanId: number = 1;
export let selectedReminderKey: string = '1|12:30|二甲双胍片';
export let planFormMode: PlanFormMode = 'create';

export const deviceStatus: DeviceStatus = {
  elderId: 1,
  name: '安心健康手环 S1',
  connected: true,
  battery: 86,
  lastSync: '今天 09:18'
};

export const medicines: Medicine[] = [
  {
    id: 1,
    elderId: 1,
    name: '二甲双胍片',
    spec: '0.5g x 30片',
    dosage: '1片',
    stock: 18,
    threshold: 10,
    note: '饭后服用，注意低血糖反应。',
    photoUri: '',
    photoLabel: '二甲',
    photoColor: '#E7F5EF',
    photoUploaded: true
  },
  {
    id: 2,
    elderId: 1,
    name: '硝苯地平控释片',
    spec: '30mg x 7片',
    dosage: '1片',
    stock: 6,
    threshold: 8,
    note: '每日固定时间服用，注意监测血压。',
    photoUri: '',
    photoLabel: '降压',
    photoColor: '#FFF7E8',
    photoUploaded: true
  },
  {
    id: 3,
    elderId: 1,
    name: '阿司匹林肠溶片',
    spec: '100mg x 30片',
    dosage: '1片',
    stock: 25,
    threshold: 10,
    note: '整片吞服，不要嚼碎。',
    photoUri: '',
    photoLabel: '阿司',
    photoColor: '#EAF2FF',
    photoUploaded: true
  }
];

export const plans: MedicationPlan[] = [
  { id: 1, elderId: 1, medicineName: '二甲双胍片', times: ['08:00', '12:30', '18:30'], dosage: '1片', mealTime: '饭后', enabled: true },
  { id: 2, elderId: 1, medicineName: '硝苯地平控释片', times: ['07:30'], dosage: '1片', mealTime: '早餐后', enabled: true },
  { id: 3, elderId: 1, medicineName: '阿司匹林肠溶片', times: ['21:00'], dosage: '1片', mealTime: '睡前', enabled: false }
];

export const todayRecords: MedicationRecord[] = [
  { elderId: 1, time: '07:30', medicineName: '硝苯地平控释片', status: '已服用', source: '老人确认' },
  { elderId: 1, time: '08:00', medicineName: '二甲双胍片', status: '已服用', source: '老人确认' },
  { elderId: 1, time: '12:30', medicineName: '二甲双胍片', status: '待服用', source: '系统未响应' },
  { elderId: 1, time: '18:30', medicineName: '二甲双胍片', status: '待服用', source: '系统未响应' }
];

export const historyRecords: MedicationRecord[] = [
  { elderId: 1, time: '5月30日 08:00', medicineName: '二甲双胍片', status: '已服用', source: '老人确认' },
  { elderId: 1, time: '5月30日 12:30', medicineName: '二甲双胍片', status: '漏服', source: '系统未响应' },
  { elderId: 1, time: '5月31日 07:30', medicineName: '硝苯地平控释片', status: '已服用', source: '设备同步' },
  { elderId: 1, time: '5月31日 18:30', medicineName: '二甲双胍片', status: '延迟服用', source: '家属补记' }
];

export const healthMetrics: HealthMetric[] = [
  { elderId: 1, type: 'heartRate', name: '心率', value: '116 次/分', numericValue: 116, unit: '次/分', time: '今天 09:18', normal: false },
  { elderId: 1, type: 'bloodPressure', name: '血压', value: '128/82 mmHg', numericValue: 128, unit: 'mmHg', time: '今天 07:20', normal: true },
  { elderId: 1, type: 'bloodSugar', name: '空腹血糖', value: '6.2 mmol/L', numericValue: 6.2, unit: 'mmol/L', time: '今天 07:10', normal: true }
];

export const healthAlerts: HealthAlert[] = [
  {
    elderId: 1,
    type: 'heartRate',
    title: '心率偏高',
    value: '116 次/分',
    time: '今天 09:18',
    notified: true
  }
];

export const careActionRecords: CareActionRecord[] = [
  { elderId: 1, time: '今天 09:18', title: '系统提醒', desc: '发现心率偏高，建议联系老人复测。', source: '设备同步' },
  { elderId: 1, time: '今天 12:35', title: '电话确认', desc: '午间服药未确认，等待家属联系。', source: '系统未响应' }
];

export const notificationPreferences: NotificationPreference[] = [
  { title: '漏服通知', desc: '老人超过提醒时间未确认时通知家属', enabled: true },
  { title: '健康异常通知', desc: '心率、血压或血糖异常时立即提醒', enabled: true },
  { title: '低库存通知', desc: '常用药低于阈值时提醒补充', enabled: true },
  { title: '每日汇总通知', desc: '每天晚间发送服药与健康摘要', enabled: false }
];

export const menus: MenuItem[] = [
  { title: '药品管理', desc: '查看药品、库存和详情', url: 'pages/MedicineLibraryPage' },
  { title: '添加药品', desc: '拍照识别或手动录入', url: 'pages/AddMedicinePage' },
  { title: '用药计划', desc: '管理长期服药计划', url: 'pages/PlanListPage' },
  { title: '新增计划', desc: '设置服药时间和频次', url: 'pages/AddPlanPage' },
  { title: '提醒详情', desc: '确认下一次服药任务', url: 'pages/ReminderDetailPage' },
  { title: '补记服药', desc: '只用于漏记后的补充记录', url: 'pages/CheckInPage' },
  { title: '记录与趋势', desc: '查看历史和完成率', url: 'pages/HistoryPage' },
  { title: '健康指标', desc: '记录血压、血糖和心率', url: 'pages/HealthMetricPage' },
  { title: '我的设置', desc: '字号和提醒设置', url: 'pages/SettingsPage' }
];

export function setSession(role: UserRole): void {
  currentSession.role = role;
  currentSession.userId = role === 'elder' ? 1 : 2;
}

export function findUserByPhone(phone: string): UserProfile | undefined {
  for (let index = 0; index < users.length; index++) {
    if (users[index].phone === phone) {
      return users[index];
    }
  }
  return undefined;
}

export function setSessionForUser(userId: number): void {
  for (let index = 0; index < users.length; index++) {
    if (users[index].id === userId) {
      currentSession.userId = users[index].id;
      currentSession.role = users[index].role;
      return;
    }
  }
}

function nextUserId(): number {
  let nextId: number = 1;
  for (let index = 0; index < users.length; index++) {
    if (users[index].id >= nextId) {
      nextId = users[index].id + 1;
    }
  }
  return nextId;
}

function nextElderId(): number {
  let nextId: number = 1;
  for (let index = 0; index < elderProfiles.length; index++) {
    if (elderProfiles[index].id >= nextId) {
      nextId = elderProfiles[index].id + 1;
    }
  }
  return nextId;
}

function createBindCode(elderId: number): string {
  const numberText: string = (2026 + elderId).toString();
  return 'AX' + numberText;
}

export function createUserAccount(phone: string, role: UserRole): UserProfile {
  const existingUser: UserProfile | undefined = findUserByPhone(phone);
  if (existingUser !== undefined) {
    return existingUser;
  }
  const userId: number = nextUserId();
  const user: UserProfile = {
    id: userId,
    name: role === 'elder' ? '新老人' : '家属用户',
    phone: phone,
    role: role,
    relation: role === 'guardian' ? '家属' : undefined
  };
  users.push(user);
  if (role === 'elder') {
    const elderId: number = nextElderId();
    const bindCode: string = createBindCode(elderId);
    user.elderId = elderId;
    elderProfiles.push({
      id: elderId,
      name: user.name,
      relation: '本人',
      bindCode: bindCode,
      contact: '暂未绑定家属',
      status: '平稳'
    });
    elderPreferences.push({
      elderId: elderId,
      largeText: false,
      strongReminder: true
    });
    selectedElderId = elderId;
  }
  return user;
}

export function ensureFamilyBinding(elderId: number, guardianId: number, code: string): void {
  for (let index = 0; index < familyBindings.length; index++) {
    if (familyBindings[index].elderId === elderId && familyBindings[index].guardianId === guardianId) {
      return;
    }
  }
  familyBindings.push({
    elderId: elderId,
    guardianId: guardianId,
    code: code,
    relation: '家属'
  });
}

export function getCurrentUser(): UserProfile {
  for (let index = 0; index < users.length; index++) {
    if (users[index].id === currentSession.userId) {
      return users[index];
    }
  }
  return users[0];
}

export function getWatchedElderId(): number {
  if (currentSession.role === 'guardian') {
    return selectedElderId;
  }
  const user: UserProfile = getCurrentUser();
  return user.elderId === undefined ? 1 : user.elderId;
}

export function selectElder(id: number): void {
  selectedElderId = id;
}

export function getCurrentElder(): ElderProfile {
  for (let index = 0; index < elderProfiles.length; index++) {
    if (elderProfiles[index].id === getWatchedElderId()) {
      return elderProfiles[index];
    }
  }
  return elderProfiles[0];
}

export function getCurrentElderPreference(): ElderPreference {
  const elderId: number = getWatchedElderId();
  for (let index = 0; index < elderPreferences.length; index++) {
    if (elderPreferences[index].elderId === elderId) {
      return elderPreferences[index];
    }
  }
  const preference: ElderPreference = {
    elderId: elderId,
    largeText: false,
    strongReminder: true
  };
  elderPreferences.push(preference);
  return preference;
}

export function setLargeTextMode(value: boolean): void {
  getCurrentElderPreference().largeText = value;
}

export function setStrongReminderMode(value: boolean): void {
  getCurrentElderPreference().strongReminder = value;
}

export function unlinkCurrentElder(): string {
  const removedName: string = getCurrentElder().name;
  if (elderProfiles.length <= 1) {
    return removedName;
  }
  for (let index = 0; index < elderProfiles.length; index++) {
    if (elderProfiles[index].id === selectedElderId) {
      elderProfiles.splice(index, 1);
      break;
    }
  }
  for (let index = 0; index < familyBindings.length; index++) {
    if (familyBindings[index].elderId === selectedElderId) {
      familyBindings.splice(index, 1);
      break;
    }
  }
  selectedElderId = elderProfiles[0].id;
  return removedName;
}

export function getElderMedicines(): Medicine[] {
  const result: Medicine[] = [];
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].elderId === getWatchedElderId()) {
      result.push(medicines[index]);
    }
  }
  return result;
}

export function getElderPlans(): MedicationPlan[] {
  const result: MedicationPlan[] = [];
  for (let index = 0; index < plans.length; index++) {
    if (plans[index].elderId === getWatchedElderId()) {
      result.push(plans[index]);
    }
  }
  return result;
}

export function addMedicationPlanForElder(medicineName: string, times: string[], dosage: string, mealTime: string): MedicationPlan {
  let nextId: number = 1;
  for (let index = 0; index < plans.length; index++) {
    if (plans[index].id >= nextId) {
      nextId = plans[index].id + 1;
    }
  }
  const elderId: number = getWatchedElderId();
  const plan: MedicationPlan = {
    id: nextId,
    elderId: elderId,
    medicineName: medicineName,
    times: times,
    dosage: dosage,
    mealTime: mealTime,
    enabled: true
  };
  plans.push(plan);
  syncTodayRecordsForPlan(plan);
  sortTodayRecords();
  return plan;
}

export function saveMedicationPlanForElder(medicineName: string, times: string[], dosage: string, mealTime: string): MedicationPlan {
  if (planFormMode === 'edit') {
    return updateSelectedMedicationPlan(medicineName, times, dosage, mealTime);
  }
  return addMedicationPlanForElder(medicineName, times, dosage, mealTime);
}

export function updateSelectedMedicationPlan(medicineName: string, times: string[], dosage: string, mealTime: string): MedicationPlan {
  const plan: MedicationPlan = getSelectedPlan();
  const oldPlan: MedicationPlan = {
    id: plan.id,
    elderId: plan.elderId,
    medicineName: plan.medicineName,
    times: plan.times,
    dosage: plan.dosage,
    mealTime: plan.mealTime,
    enabled: plan.enabled
  };
  removeUnfinishedTodayRecordsForPlan(oldPlan);
  plan.medicineName = medicineName;
  plan.times = times;
  plan.dosage = dosage;
  plan.mealTime = mealTime;
  if (plan.enabled) {
    syncTodayRecordsForPlan(plan);
    sortTodayRecords();
  }
  return plan;
}

export function startCreatePlan(): void {
  planFormMode = 'create';
}

export function startCreatePlanForMedicine(medicineName: string): void {
  selectedMedicineName = medicineName;
  planFormMode = 'create';
}

export function startEditSelectedPlan(): void {
  planFormMode = 'edit';
}

export function isEditingMedicationPlan(): boolean {
  return planFormMode === 'edit';
}

export function getPlanFormTitle(): string {
  return planFormMode === 'edit' ? '修改用药计划' : '新增用药计划';
}

export function getPlanFormMedicine(): string {
  return planFormMode === 'edit' ? getSelectedPlan().medicineName : selectedMedicineName;
}

export function getPlanFormTime(index: number): string {
  if (planFormMode !== 'edit') {
    if (index === 0) {
      return '08:00';
    }
    if (index === 1) {
      return '12:30';
    }
    return '18:30';
  }
  const plan: MedicationPlan = getSelectedPlan();
  return plan.times.length > index ? plan.times[index] : '';
}

export function getPlanFormDosage(): string {
  return planFormMode === 'edit' ? getSelectedPlan().dosage : '1片';
}

export function getPlanFormMealTime(): string {
  return planFormMode === 'edit' ? getSelectedPlan().mealTime : '饭后';
}

function syncTodayRecordsForPlan(plan: MedicationPlan): void {
  for (let timeIndex = 0; timeIndex < plan.times.length; timeIndex++) {
    let exists: boolean = false;
    for (let recordIndex = 0; recordIndex < todayRecords.length; recordIndex++) {
      if (todayRecords[recordIndex].elderId === plan.elderId &&
        todayRecords[recordIndex].medicineName === plan.medicineName &&
        todayRecords[recordIndex].time === plan.times[timeIndex]) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      todayRecords.push({
        elderId: plan.elderId,
        time: plan.times[timeIndex],
        medicineName: plan.medicineName,
        status: '待服用',
        source: '系统未响应'
      });
    }
  }
}

function removeUnfinishedTodayRecordsForPlan(plan: MedicationPlan): void {
  for (let index = todayRecords.length - 1; index >= 0; index--) {
    if (todayRecords[index].elderId === plan.elderId &&
      todayRecords[index].medicineName === plan.medicineName &&
      todayRecords[index].status !== '已服用') {
      for (let timeIndex = 0; timeIndex < plan.times.length; timeIndex++) {
        if (todayRecords[index].time === plan.times[timeIndex]) {
          todayRecords.splice(index, 1);
          break;
        }
      }
    }
  }
}

function sortTodayRecords(): void {
  todayRecords.sort((left: MedicationRecord, right: MedicationRecord): number => {
    if (left.elderId !== right.elderId) {
      return left.elderId - right.elderId;
    }
    if (left.time < right.time) {
      return -1;
    }
    if (left.time > right.time) {
      return 1;
    }
    return 0;
  });
}

export function getElderTodayRecords(): MedicationRecord[] {
  const result: MedicationRecord[] = [];
  for (let index = 0; index < todayRecords.length; index++) {
    if (todayRecords[index].elderId === getWatchedElderId()) {
      result.push(todayRecords[index]);
    }
  }
  return result;
}

export function getElderHistoryRecords(): MedicationRecord[] {
  const result: MedicationRecord[] = [];
  for (let index = 0; index < historyRecords.length; index++) {
    if (historyRecords[index].elderId === getWatchedElderId()) {
      result.push(historyRecords[index]);
    }
  }
  return result;
}

export function getElderHealthMetrics(): HealthMetric[] {
  const result: HealthMetric[] = [];
  for (let index = 0; index < healthMetrics.length; index++) {
    if (healthMetrics[index].elderId === getWatchedElderId()) {
      result.push(healthMetrics[index]);
    }
  }
  return result;
}

export function getElderHealthAlerts(): HealthAlert[] {
  const result: HealthAlert[] = [];
  for (let index = 0; index < healthAlerts.length; index++) {
    if (healthAlerts[index].elderId === getWatchedElderId() && healthAlerts[index].resolved !== true) {
      result.push(healthAlerts[index]);
    }
  }
  return result;
}

export function markRefillArranged(medicineName: string): void {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].elderId === getWatchedElderId() && medicines[index].name === medicineName) {
      medicines[index].refillArranged = true;
      return;
    }
  }
}

export function getElderCareActionRecords(): CareActionRecord[] {
  const result: CareActionRecord[] = [];
  for (let index = 0; index < careActionRecords.length; index++) {
    if (careActionRecords[index].elderId === getWatchedElderId()) {
      result.push(careActionRecords[index]);
    }
  }
  return result;
}

export function addCareActionRecord(title: string, desc: string, source: string): void {
  careActionRecords.unshift({
    elderId: getWatchedElderId(),
    time: '刚刚',
    title: title,
    desc: desc,
    source: source
  });
}

export function isNotificationEnabled(title: string): boolean {
  for (let index = 0; index < notificationPreferences.length; index++) {
    if (notificationPreferences[index].title === title) {
      return notificationPreferences[index].enabled;
    }
  }
  return false;
}

export function setNotificationPreference(title: string, enabled: boolean): void {
  for (let index = 0; index < notificationPreferences.length; index++) {
    if (notificationPreferences[index].title === title) {
      notificationPreferences[index].enabled = enabled;
      addCareActionRecord('通知设置', title + (enabled ? '已开启。' : '已关闭。'), '看护设置');
      return;
    }
  }
}

function addHealthMetricRecord(type: HealthMetricType, name: string, value: string, numericValue: number, unit: string, normal: boolean, alertTitle: string): void {
  healthMetrics.unshift({
    elderId: getWatchedElderId(),
    type: type,
    name: name,
    value: value,
    numericValue: numericValue,
    unit: unit,
    time: '刚刚',
    normal: normal
  });
  if (!normal) {
    const notifyEnabled: boolean = isNotificationEnabled('健康异常通知');
    healthAlerts.unshift({
      elderId: getWatchedElderId(),
      type: type,
      title: alertTitle,
      value: value,
      time: '刚刚',
      notified: notifyEnabled
    });
    addCareActionRecord(notifyEnabled ? '健康异常通知' : '健康异常记录', name + '记录为' + value + (notifyEnabled ? '，已通知看护人。' : '，通知已关闭，仅保留记录。'), '健康记录');
  }
}

export function recordHeartRateMetric(rateText: string): boolean {
  const rate: number = Number(rateText);
  const normal: boolean = rate >= 50 && rate <= 110;
  addHealthMetricRecord('heartRate', '心率', rateText + ' 次/分', rate, '次/分', normal, rate > 110 ? '心率偏高' : '心率偏低');
  return normal;
}

export function recordBloodPressureMetric(pressureText: string): boolean {
  const parts: string[] = pressureText.split('/');
  const systolic: number = parts.length > 0 ? Number(parts[0]) : 0;
  const diastolic: number = parts.length > 1 ? Number(parts[1]) : 0;
  const normal: boolean = systolic >= 90 && systolic <= 139 && diastolic >= 60 && diastolic <= 89;
  const alertTitle: string = systolic >= 140 || diastolic >= 90 ? '血压偏高' : '血压偏低';
  addHealthMetricRecord('bloodPressure', '血压', pressureText + ' mmHg', systolic, 'mmHg', normal, alertTitle);
  return normal;
}

export function recordBloodSugarMetric(sugarText: string): boolean {
  const sugar: number = Number(sugarText);
  const normal: boolean = sugar >= 3.9 && sugar <= 6.1;
  addHealthMetricRecord('bloodSugar', '空腹血糖', sugarText + ' mmol/L', sugar, 'mmol/L', normal, sugar > 6.1 ? '血糖偏高' : '血糖偏低');
  return normal;
}

export function addRefillTodo(medicineName: string): void {
  markRefillArranged(medicineName);
}

export function confirmFirstPendingRecordByGuardian(): MedicationRecord | undefined {
  for (let index = 0; index < todayRecords.length; index++) {
    if (todayRecords[index].elderId === getWatchedElderId() && todayRecords[index].status !== '已服用') {
      decreaseMedicineStockAfterDose(todayRecords[index].medicineName);
      todayRecords[index].status = '已服用';
      todayRecords[index].source = '家属补记';
      historyRecords.unshift({
        elderId: todayRecords[index].elderId,
        time: '今天 ' + todayRecords[index].time,
        medicineName: todayRecords[index].medicineName,
        status: '已服用',
        source: '家属补记'
      });
      return todayRecords[index];
    }
  }
  return undefined;
}

export function markHealthRetestRequested(): void {
  for (let index = 0; index < healthAlerts.length; index++) {
    if (healthAlerts[index].elderId === getWatchedElderId()) {
      healthAlerts[index].retestRequested = true;
      healthAlerts[index].notified = true;
      return;
    }
  }
}

export function selectMedicine(name: string): void {
  selectedMedicineName = name;
}

export function selectPlan(id: number): void {
  selectedPlanId = id;
}

export function deleteSelectedPlan(): string {
  const plan: MedicationPlan = getSelectedPlan();
  const removedName: string = plan.medicineName;
  removeUnfinishedTodayRecordsForPlan(plan);
  for (let index = 0; index < plans.length; index++) {
    if (plans[index].id === plan.id) {
      plans.splice(index, 1);
      break;
    }
  }
  const currentPlans: MedicationPlan[] = getElderPlans();
  selectedPlanId = currentPlans.length > 0 ? currentPlans[0].id : 0;
  return removedName;
}

export function setSelectedPlanEnabled(enabled: boolean): void {
  const plan: MedicationPlan = getSelectedPlan();
  plan.enabled = enabled;
  if (enabled) {
    syncTodayRecordsForPlan(plan);
    sortTodayRecords();
  } else {
    removeUnfinishedTodayRecordsForPlan(plan);
  }
}

export function selectReminder(record: MedicationRecord): void {
  selectedReminderKey = record.elderId.toString() + '|' + record.time + '|' + record.medicineName;
}

export function getSelectedMedicine(): Medicine {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].name === selectedMedicineName) {
      return medicines[index];
    }
  }
  return medicines[0];
}

export function getSelectedPlan(): MedicationPlan {
  for (let index = 0; index < plans.length; index++) {
    if (plans[index].id === selectedPlanId) {
      return plans[index];
    }
  }
  return getElderPlans().length > 0 ? getElderPlans()[0] : plans[0];
}

export function getSelectedReminder(): MedicationRecord {
  for (let index = 0; index < todayRecords.length; index++) {
    const key: string = todayRecords[index].elderId.toString() + '|' + todayRecords[index].time + '|' + todayRecords[index].medicineName;
    if (key === selectedReminderKey) {
      return todayRecords[index];
    }
  }
  const currentRecords: MedicationRecord[] = getElderTodayRecords();
  return currentRecords.length > 0 ? currentRecords[0] : todayRecords[0];
}

export function updateReminderStatus(record: MedicationRecord, status: string, source: RecordSource): void {
  if (record.status === status && record.source === source) {
    return;
  }
  const wasDone: boolean = record.status === '已服用';
  if (!wasDone && status === '已服用') {
    decreaseMedicineStockAfterDose(record.medicineName);
  } else if (wasDone && status !== '已服用') {
    restoreMedicineStockAfterDoseCorrection(record.medicineName);
  }
  record.status = status;
  record.source = source;
  historyRecords.unshift({
    elderId: record.elderId,
    time: '今天 ' + record.time,
    medicineName: record.medicineName,
    status: status,
    source: source
  });
  if (status === '漏服') {
    if (isNotificationEnabled('漏服通知')) {
      addCareActionRecord('漏服通知', record.time + ' ' + record.medicineName + '已记录漏服，已通知看护人。', source);
    } else {
      addCareActionRecord('漏服记录', record.time + ' ' + record.medicineName + '已记录漏服，漏服通知已关闭。', source);
    }
  }
}

export function postponeMedicationReminder(record: MedicationRecord, source: RecordSource): void {
  if (record.status === '已服用') {
    return;
  }
  record.status = '稍后提醒';
  record.source = source;
  addCareActionRecord('稍后提醒', record.time + ' ' + record.medicineName + '已设置稍后提醒，等待后续确认。', source);
}

export function getMedicinePlanText(name: string): string {
  for (let index = 0; index < plans.length; index++) {
    if (plans[index].medicineName === name) {
      return plans[index].times.join(' / ') + '  ' + plans[index].dosage + '  ' + plans[index].mealTime;
    }
  }
  return '暂未设置用药计划';
}

export function getMedicinePhotoLabel(name: string): string {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].name === name) {
      return medicines[index].photoLabel;
    }
  }
  return name.length >= 2 ? name.substring(0, 2) : '药品';
}

export function getMedicinePhotoColor(name: string): string {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].name === name) {
      return medicines[index].photoColor;
    }
  }
  return '#E7F5EF';
}

export function getMedicinePhotoUri(name: string): string {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].name === name) {
      return medicines[index].photoUri;
    }
  }
  return '';
}

export function isMedicinePhotoUploaded(name: string): boolean {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].name === name) {
      return medicines[index].photoUploaded;
    }
  }
  return false;
}

export function addMedicineForElder(name: string, spec: string, dosage: string, stock: number, note: string, photoUri: string, photoLabel: string, photoColor: string, photoUploaded: boolean): boolean {
  const savedName: string = name === '' ? '未命名药品' : name;
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].elderId === getWatchedElderId() && medicines[index].name === savedName) {
      medicines[index].spec = spec === '' ? medicines[index].spec : spec;
      medicines[index].dosage = dosage === '' ? medicines[index].dosage : dosage;
      medicines[index].stock = stock;
      medicines[index].note = note === '' ? medicines[index].note : note;
      if (photoUploaded || photoUri !== '') {
        medicines[index].photoUri = photoUri;
        medicines[index].photoLabel = photoLabel === '' ? medicines[index].photoLabel : photoLabel;
        medicines[index].photoColor = photoColor === '' ? medicines[index].photoColor : photoColor;
        medicines[index].photoUploaded = photoUploaded;
      }
      medicines[index].refillArranged = stock > medicines[index].threshold ? false : medicines[index].refillArranged;
      return false;
    }
  }
  const nextId: number = medicines.length + 1;
  medicines.push({
    id: nextId,
    elderId: getWatchedElderId(),
    name: savedName,
    spec: spec === '' ? '规格待补充' : spec,
    dosage: dosage === '' ? '按医嘱' : dosage,
    stock: stock,
    threshold: 8,
    note: note === '' ? '请本人或监护人与医嘱核对后使用。' : note,
    photoUri: photoUri,
    photoLabel: photoLabel === '' ? (savedName.length >= 2 ? savedName.substring(0, 2) : '药品') : photoLabel,
    photoColor: photoColor === '' ? '#E7F5EF' : photoColor,
    photoUploaded: photoUploaded
  });
  return true;
}

export function updateMedicineStock(name: string, stock: number): StockUpdateResult {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].elderId === getWatchedElderId() && medicines[index].name === name) {
      const wasArranged: boolean = medicines[index].refillArranged === true;
      medicines[index].stock = stock;
      const lowStock: boolean = stock <= medicines[index].threshold;
      if (!lowStock) {
        medicines[index].refillArranged = false;
      }
      addCareActionRecord(lowStock ? '库存仍偏低' : '库存已更新', name + '库存更新为 ' + stock.toString() + '。', '药品管理');
      return {
        found: true,
        lowStock: lowStock,
        refillCleared: wasArranged && !lowStock
      };
    }
  }
  return {
    found: false,
    lowStock: false,
    refillCleared: false
  };
}

function decreaseMedicineStockAfterDose(medicineName: string): void {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].elderId === getWatchedElderId() && medicines[index].name === medicineName) {
      const previousStock: number = medicines[index].stock;
      medicines[index].stock = medicines[index].stock > 0 ? medicines[index].stock - 1 : 0;
      if (previousStock > medicines[index].threshold && medicines[index].stock <= medicines[index].threshold) {
        medicines[index].refillArranged = false;
        if (isNotificationEnabled('低库存通知')) {
          addCareActionRecord('低库存通知', medicineName + '库存已低于提醒阈值，请安排补药。', '服药记录');
        } else {
          addCareActionRecord('低库存记录', medicineName + '库存已低于提醒阈值，低库存通知已关闭。', '服药记录');
        }
      }
      return;
    }
  }
}

function restoreMedicineStockAfterDoseCorrection(medicineName: string): void {
  for (let index = 0; index < medicines.length; index++) {
    if (medicines[index].elderId === getWatchedElderId() && medicines[index].name === medicineName) {
      medicines[index].stock++;
      return;
    }
  }
}

export function markFirstPendingRecordDone(): void {
  for (let index = 0; index < todayRecords.length; index++) {
    if (todayRecords[index].elderId === getWatchedElderId() && todayRecords[index].status !== '已服用') {
      decreaseMedicineStockAfterDose(todayRecords[index].medicineName);
      todayRecords[index].status = '已服用';
      todayRecords[index].source = '老人确认';
      historyRecords.unshift({
        elderId: todayRecords[index].elderId,
        time: '今天 ' + todayRecords[index].time,
        medicineName: todayRecords[index].medicineName,
        status: '已服用',
        source: '老人确认'
      });
      break;
    }
  }
}

export function connectHealthDevice(): void {
  deviceStatus.connected = true;
  deviceStatus.lastSync = '刚刚同步';
  healthMetrics.unshift({
    elderId: getWatchedElderId(),
    type: 'heartRate',
    name: '心率',
    value: '118 次/分',
    numericValue: 118,
    unit: '次/分',
    time: '刚刚',
    normal: false
  });
  healthAlerts.unshift({
    elderId: getWatchedElderId(),
    type: 'heartRate',
    title: '心率偏高',
    value: '118 次/分',
    time: '刚刚',
    notified: true
  });
}

export function syncRetestHeartRate(): void {
  deviceStatus.connected = true;
  deviceStatus.lastSync = '刚刚同步';
  healthMetrics.unshift({
    elderId: getWatchedElderId(),
    type: 'heartRate',
    name: '心率',
    value: '96 次/分',
    numericValue: 96,
    unit: '次/分',
    time: '刚刚',
    normal: true
  });
  for (let index = 0; index < healthAlerts.length; index++) {
    if (healthAlerts[index].elderId === getWatchedElderId() && healthAlerts[index].type === 'heartRate') {
      healthAlerts[index].retestRequested = true;
      healthAlerts[index].resolved = true;
      return;
    }
  }
}
