export type UserRole = 'elder' | 'guardian';
export type HealthMetricType = 'heartRate' | 'bloodPressure' | 'bloodSugar';

export interface MockUser {
  id: number;
  name: string;
  phone: string;
  role: UserRole;
  relation?: string;
}

export interface MockBinding {
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
  title: string;
  desc: string;
  level: string;
  action: string;
  url: string;
}

export interface NotificationPreference {
  title: string;
  desc: string;
  enabled: boolean;
}

export const mockUsers: MockUser[] = [
  { id: 1, name: '张阿姨', phone: '13800000001', role: 'elder' },
  { id: 2, name: '李女士', phone: '13800000002', role: 'guardian', relation: '女儿' }
];

export const mockBindings: MockBinding[] = [
  { elderId: 1, guardianId: 2, code: 'AX2026', relation: '女儿' }
];

export const currentSession: Session = {
  userId: 1,
  role: 'elder'
};

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
  }
];

export const plans: MedicationPlan[] = [
  { id: 1, elderId: 1, medicineName: '二甲双胍片', times: ['08:00', '12:30', '18:30'], dosage: '1片', mealTime: '饭后', enabled: true },
  { id: 2, elderId: 1, medicineName: '硝苯地平控释片', times: ['07:30'], dosage: '1片', mealTime: '早餐后', enabled: true },
  { id: 3, elderId: 1, medicineName: '阿司匹林肠溶片', times: ['21:00'], dosage: '1片', mealTime: '睡前', enabled: false }
];

export const todayRecords: MedicationRecord[] = [
  { elderId: 1, time: '07:30', medicineName: '硝苯地平控释片', status: '已服用' },
  { elderId: 1, time: '08:00', medicineName: '二甲双胍片', status: '已服用' },
  { elderId: 1, time: '12:30', medicineName: '二甲双胍片', status: '待服用' },
  { elderId: 1, time: '18:30', medicineName: '二甲双胍片', status: '待服用' }
];

export const historyRecords: MedicationRecord[] = [
  { elderId: 1, time: '5月30日 08:00', medicineName: '二甲双胍片', status: '已服用' },
  { elderId: 1, time: '5月30日 12:30', medicineName: '二甲双胍片', status: '漏服' },
  { elderId: 1, time: '5月31日 07:30', medicineName: '硝苯地平控释片', status: '已服用' },
  { elderId: 1, time: '5月31日 18:30', medicineName: '二甲双胍片', status: '延迟服用' }
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

export const careTodos: CareTodo[] = [
  {
    title: '确认午间服药',
    desc: '12:30 二甲双胍片尚未确认，建议电话确认。',
    level: '高优先级',
    action: '生成话术',
    url: 'pages/AIAssistantPage'
  },
  {
    title: '复测心率',
    desc: '今天 09:18 心率 116 次/分，建议休息后复测。',
    level: '需关注',
    action: '查看健康',
    url: 'pages/HealthMetricPage'
  },
  {
    title: '补充低库存药品',
    desc: '硝苯地平控释片剩余 6 片，低于提醒阈值。',
    level: '待处理',
    action: '去库存',
    url: 'pages/InventoryPage'
  },
  {
    title: '晚间用药提醒',
    desc: '18:30 二甲双胍片，建议提前 10 分钟轻提醒。',
    level: '计划中',
    action: '看计划',
    url: 'pages/PlanListPage'
  }
];

export const notificationPreferences: NotificationPreference[] = [
  { title: '漏服通知', desc: '老人超过提醒时间未确认时通知家属', enabled: true },
  { title: '健康异常通知', desc: '心率、血压或血糖异常时立即提醒', enabled: true },
  { title: '低库存通知', desc: '常用药低于阈值时提醒补充', enabled: true },
  { title: '每日汇总通知', desc: '每天晚间发送服药与健康摘要', enabled: false }
];

export const menus: MenuItem[] = [
  { title: '药品库', desc: '查看和管理常用药品', url: 'pages/MedicineLibraryPage' },
  { title: '新增药品', desc: '录入药名、剂量和库存', url: 'pages/AddMedicinePage' },
  { title: '用药计划', desc: '管理长期服药计划', url: 'pages/PlanListPage' },
  { title: '新增计划', desc: '设置服药时间和频次', url: 'pages/AddPlanPage' },
  { title: '提醒详情', desc: '确认下一次服药任务', url: 'pages/ReminderDetailPage' },
  { title: '服药打卡', desc: '记录已服、稍后或漏服', url: 'pages/CheckInPage' },
  { title: '历史记录', desc: '按日期回顾服药情况', url: 'pages/HistoryPage' },
  { title: '统计分析', desc: '查看完成率和漏服次数', url: 'pages/StatsPage' },
  { title: '库存管理', desc: '跟踪药量不足提醒', url: 'pages/InventoryPage' },
  { title: '健康指标', desc: '记录血压、血糖和心率', url: 'pages/HealthMetricPage' },
  { title: '家属协助', desc: '绑定监护人并同步异常提醒', url: 'pages/FamilyAssistPage' },
  { title: '我的设置', desc: '字体、强提醒和本地备份', url: 'pages/SettingsPage' }
];

export function setSession(role: UserRole): void {
  currentSession.role = role;
  currentSession.userId = role === 'elder' ? 1 : 2;
}

export function getCurrentUser(): MockUser {
  return currentSession.role === 'guardian' ? mockUsers[1] : mockUsers[0];
}

export function getWatchedElderId(): number {
  return 1;
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
    if (todayRecords[index].status === '待服用') {
      todayRecords[index].status = '已服用';
      historyRecords.unshift({
        elderId: todayRecords[index].elderId,
        time: '今天 ' + todayRecords[index].time,
        medicineName: todayRecords[index].medicineName,
        status: '已服用'
      });
      break;
    }
  }
}

export function connectMockDevice(): void {
  deviceStatus.connected = true;
  deviceStatus.lastSync = '刚刚同步';
  healthMetrics.unshift({
    elderId: 1,
    type: 'heartRate',
    name: '心率',
    value: '118 次/分',
    numericValue: 118,
    unit: '次/分',
    time: '刚刚',
    normal: false
  });
  healthAlerts.unshift({
    elderId: 1,
    type: 'heartRate',
    title: '心率偏高',
    value: '118 次/分',
    time: '刚刚',
    notified: true
  });
}
