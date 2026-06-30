export type UserRole = 'elder' | 'guardian';
export type HealthMetricType = 'heartRate' | 'bloodPressure' | 'bloodSugar';
export type RecordSource = '老人确认' | '家属补记' | '设备同步' | '系统未响应';

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
}

export interface FamilyBinding {
  elderId: number;
  guardianId: number;
  code: string;
  relation: string;
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

export interface CareTodo {
  elderId: number;
  title: string;
  desc: string;
  level: string;
  action: string;
  url: string;
}

export interface CareActionRecord {
  elderId: number;
  time: string;
  title: string;
  desc: string;
  source: string;
}

export interface NotificationPreference {
  title: string;
  desc: string;
  enabled: boolean;
}

export const users: UserProfile[] = [
  { id: 1, name: '张阿姨', phone: '13800000001', role: 'elder' },
  { id: 2, name: '李女士', phone: '13800000002', role: 'guardian', relation: '女儿' }
];

export const familyBindings: FamilyBinding[] = [
  { elderId: 1, guardianId: 2, code: 'AX2026', relation: '女儿' }
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

export const deviceStatus: DeviceStatus = {
  elderId: 1,
  name: '安心健康手环 S1',
  connected: false,
  battery: 86,
  lastSync: '尚未同步'
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
  },
  {
    id: 4,
    elderId: 3,
    name: '瑞舒伐他汀钙片',
    spec: '10mg x 28片',
    dosage: '1片',
    stock: 16,
    threshold: 7,
    note: '晚饭后服用，注意定期复查血脂。',
    photoUri: '',
    photoLabel: '降脂',
    photoColor: '#EAF2FF',
    photoUploaded: true
  },
  {
    id: 5,
    elderId: 3,
    name: '缬沙坦胶囊',
    spec: '80mg x 14粒',
    dosage: '1粒',
    stock: 5,
    threshold: 6,
    note: '每日固定时间服用，注意监测血压。',
    photoUri: '',
    photoLabel: '血压',
    photoColor: '#FFF7E8',
    photoUploaded: true
  }
];

export const plans: MedicationPlan[] = [
  { id: 1, elderId: 1, medicineName: '二甲双胍片', times: ['08:00', '12:30', '18:30'], dosage: '1片', mealTime: '饭后', enabled: true },
  { id: 2, elderId: 1, medicineName: '硝苯地平控释片', times: ['07:30'], dosage: '1片', mealTime: '早餐后', enabled: true },
  { id: 3, elderId: 1, medicineName: '阿司匹林肠溶片', times: ['21:00'], dosage: '1片', mealTime: '睡前', enabled: false },
  { id: 4, elderId: 3, medicineName: '瑞舒伐他汀钙片', times: ['20:30'], dosage: '1片', mealTime: '晚饭后', enabled: true },
  { id: 5, elderId: 3, medicineName: '缬沙坦胶囊', times: ['08:30'], dosage: '1粒', mealTime: '早餐后', enabled: true }
];

export const todayRecords: MedicationRecord[] = [
  { elderId: 1, time: '07:30', medicineName: '硝苯地平控释片', status: '已服用', source: '老人确认' },
  { elderId: 1, time: '08:00', medicineName: '二甲双胍片', status: '已服用', source: '老人确认' },
  { elderId: 1, time: '12:30', medicineName: '二甲双胍片', status: '待服用', source: '系统未响应' },
  { elderId: 1, time: '18:30', medicineName: '二甲双胍片', status: '待服用', source: '系统未响应' },
  { elderId: 3, time: '08:30', medicineName: '缬沙坦胶囊', status: '已服用', source: '老人确认' },
  { elderId: 3, time: '20:30', medicineName: '瑞舒伐他汀钙片', status: '待服用', source: '系统未响应' }
];

export const historyRecords: MedicationRecord[] = [
  { elderId: 1, time: '5月30日 08:00', medicineName: '二甲双胍片', status: '已服用', source: '老人确认' },
  { elderId: 1, time: '5月30日 12:30', medicineName: '二甲双胍片', status: '漏服', source: '系统未响应' },
  { elderId: 1, time: '5月31日 07:30', medicineName: '硝苯地平控释片', status: '已服用', source: '设备同步' },
  { elderId: 1, time: '5月31日 18:30', medicineName: '二甲双胍片', status: '延迟服用', source: '家属补记' },
  { elderId: 3, time: '5月31日 08:30', medicineName: '缬沙坦胶囊', status: '已服用', source: '老人确认' },
  { elderId: 3, time: '5月31日 20:30', medicineName: '瑞舒伐他汀钙片', status: '已服用', source: '老人确认' }
];

export const healthMetrics: HealthMetric[] = [
  { elderId: 1, type: 'heartRate', name: '心率', value: '116 次/分', numericValue: 116, unit: '次/分', time: '今天 09:18', normal: false },
  { elderId: 1, type: 'bloodPressure', name: '血压', value: '128/82 mmHg', numericValue: 128, unit: 'mmHg', time: '今天 07:20', normal: true },
  { elderId: 1, type: 'bloodSugar', name: '空腹血糖', value: '6.2 mmol/L', numericValue: 6.2, unit: 'mmol/L', time: '今天 07:10', normal: true },
  { elderId: 3, type: 'heartRate', name: '心率', value: '78 次/分', numericValue: 78, unit: '次/分', time: '今天 08:40', normal: true },
  { elderId: 3, type: 'bloodPressure', name: '血压', value: '132/84 mmHg', numericValue: 132, unit: 'mmHg', time: '今天 08:35', normal: true },
  { elderId: 3, type: 'bloodSugar', name: '空腹血糖', value: '5.8 mmol/L', numericValue: 5.8, unit: 'mmol/L', time: '今天 07:30', normal: true }
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

export const careTodos: CareTodo[] = [
  {
    elderId: 1,
    title: '确认午间服药',
    desc: '12:30 二甲双胍片尚未确认，建议电话确认。',
    level: '高优先级',
    action: '电话确认',
    url: 'pages/FamilyAssistPage'
  },
  {
    elderId: 1,
    title: '复测心率',
    desc: '今天 09:18 心率 116 次/分，建议休息后复测。',
    level: '需关注',
    action: '发复测提醒',
    url: 'pages/HealthMetricPage'
  },
  {
    elderId: 1,
    title: '补充低库存药品',
    desc: '硝苯地平控释片剩余 6 片，低于提醒阈值。',
    level: '待处理',
    action: '处理补药',
    url: 'pages/InventoryPage'
  },
  {
    elderId: 1,
    title: '晚间用药提醒',
    desc: '18:30 二甲双胍片，建议提前 10 分钟轻提醒。',
    level: '计划中',
    action: '调整提醒',
    url: 'pages/PlanListPage'
  },
  {
    elderId: 3,
    title: '晚间服药提醒',
    desc: '20:30 瑞舒伐他汀钙片待服用，建议晚饭后提醒。',
    level: '计划中',
    action: '提醒老人',
    url: 'pages/PlanListPage'
  },
  {
    elderId: 3,
    title: '补充血压药',
    desc: '缬沙坦胶囊剩余 5 粒，低于提醒阈值。',
    level: '待处理',
    action: '处理补药',
    url: 'pages/InventoryPage'
  }
];

export const careActionRecords: CareActionRecord[] = [
  { elderId: 1, time: '今天 09:18', title: '系统提醒', desc: '发现心率偏高，建议联系老人复测。', source: '设备同步' },
  { elderId: 1, time: '今天 12:35', title: '电话确认', desc: '午间服药未确认，等待家属联系。', source: '系统未响应' },
  { elderId: 3, time: '今天 08:45', title: '服药确认', desc: '早间血压药已由老人确认。', source: '老人确认' }
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
  { title: '记录分析', desc: '查看历史和完成率', url: 'pages/HistoryPage' },
  { title: '健康指标', desc: '记录血压、血糖和心率', url: 'pages/HealthMetricPage' },
  { title: '家属协助', desc: '绑定监护人并同步异常提醒', url: 'pages/FamilyAssistPage' },
  { title: '我的设置', desc: '字号和提醒设置', url: 'pages/SettingsPage' }
];

export function setSession(role: UserRole): void {
  currentSession.role = role;
  currentSession.userId = role === 'elder' ? 1 : 2;
}

export function getCurrentUser(): UserProfile {
  return currentSession.role === 'guardian' ? users[1] : users[0];
}

export function getWatchedElderId(): number {
  return currentSession.role === 'guardian' ? selectedElderId : 1;
}

export function selectElder(id: number): void {
  selectedElderId = id;
}

export function getSelectedElderId(): number {
  return selectedElderId;
}

export function getCurrentElder(): ElderProfile {
  for (let index = 0; index < elderProfiles.length; index++) {
    if (elderProfiles[index].id === getWatchedElderId()) {
      return elderProfiles[index];
    }
  }
  return elderProfiles[0];
}

export function getGuardianElders(): ElderProfile[] {
  return elderProfiles;
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
    if (healthAlerts[index].elderId === getWatchedElderId()) {
      result.push(healthAlerts[index]);
    }
  }
  return result;
}

export function getElderCareTodos(): CareTodo[] {
  const result: CareTodo[] = [];
  for (let index = 0; index < careTodos.length; index++) {
    if (careTodos[index].elderId === getWatchedElderId()) {
      result.push(careTodos[index]);
    }
  }
  return result;
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

export function addCareTodo(title: string, desc: string, level: string, action: string, url: string): void {
  for (let index = 0; index < careTodos.length; index++) {
    if (careTodos[index].elderId === getWatchedElderId() && careTodos[index].title === title) {
      careTodos[index].desc = desc;
      careTodos[index].level = level;
      careTodos[index].action = action;
      careTodos[index].url = url;
      return;
    }
  }
  careTodos.unshift({
    elderId: getWatchedElderId(),
    title: title,
    desc: desc,
    level: level,
    action: action,
    url: url
  });
}

export function addRefillTodo(medicineName: string): void {
  addCareTodo('补药任务跟进', medicineName + '已安排补充，请完成购买后回到记录页确认。', '待处理', '查看库存', 'pages/InventoryPage');
}

export function selectMedicine(name: string): void {
  selectedMedicineName = name;
}

export function selectPlan(id: number): void {
  selectedPlanId = id;
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

export function addMedicineForElder(name: string, spec: string, dosage: string, stock: number, note: string, photoUri: string, photoLabel: string, photoColor: string, photoUploaded: boolean): void {
  const nextId: number = medicines.length + 1;
  const savedName: string = name === '' ? '未命名药品' : name;
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
}

export function markFirstPendingRecordDone(): void {
  for (let index = 0; index < todayRecords.length; index++) {
    if (todayRecords[index].elderId === getWatchedElderId() && todayRecords[index].status === '待服用') {
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
