import { router, promptAction } from '@kit.ArkUI';
import {
  connectMockDevice,
  deviceStatus,
  HealthMetric,
  healthAlerts,
  healthMetrics
} from '../models/AppData';

@Entry
@Component
struct HealthMetricPage {
  @State heartRate: string = '76';
  @State bloodPressure: string = '130/85';
  @State bloodSugar: string = '6.2';
  @State refreshToken: number = 0;

  private saveHeartRate(): void {
    const rate: number = Number(this.heartRate);
    const isNormal: boolean = rate >= 50 && rate <= 110;
    healthMetrics.unshift({
      elderId: 1,
      type: 'heartRate',
      name: '心率',
      value: this.heartRate + ' 次/分',
      numericValue: rate,
      unit: '次/分',
      time: '刚刚',
      normal: isNormal
    });
    if (!isNormal) {
      healthAlerts.unshift({
        elderId: 1,
        type: 'heartRate',
        title: rate > 110 ? '心率偏高' : '心率偏低',
        value: this.heartRate + ' 次/分',
        time: '刚刚',
        notified: true
      });
      promptAction.showToast({ message: '心率异常，已模拟提醒监护人' });
    } else {
      promptAction.showToast({ message: '心率记录已保存' });
    }
    this.refreshToken++;
  }

  private saveRoutineMetric(): void {
    healthMetrics.unshift({
      elderId: 1,
      type: 'bloodPressure',
      name: '血压',
      value: this.bloodPressure + ' mmHg',
      numericValue: 0,
      unit: 'mmHg',
      time: '刚刚',
      normal: true
    });
    healthMetrics.unshift({
      elderId: 1,
      type: 'bloodSugar',
      name: '血糖',
      value: this.bloodSugar + ' mmol/L',
      numericValue: Number(this.bloodSugar),
      unit: 'mmol/L',
      time: '刚刚',
      normal: true
    });
    this.refreshToken++;
    promptAction.showToast({ message: '健康指标已保存（模拟）' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('健康监测')
        this.DeviceConnectCard()
        this.HeartRateCard()
        this.RoutineMetricCard()
        this.AlertCard()
        this.SectionTitle('最近指标')
        ForEach(healthMetrics, (item: HealthMetric) => {
          this.MetricRow(item)
        }, (item: HealthMetric) => item.name + item.time + item.value + this.refreshToken.toString())
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder DeviceConnectCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 5 }) {
          Text(deviceStatus.name)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text(deviceStatus.connected ? '已连接，' + deviceStatus.lastSync : '未连接，点击下方按钮模拟搜索和连接')
            .fontSize(16)
            .lineHeight(23)
            .fontColor('#52635F')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(deviceStatus.battery.toString() + '%')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0B7A5B')
      }
      .width('100%')
      Button(deviceStatus.connected ? '重新同步心率' : '搜索并连接手环')
        .width('100%')
        .height(52)
        .fontSize(19)
        .borderRadius(20)
        .backgroundColor('#0B7A5B')
        .onClick(() => {
          connectMockDevice();
          this.refreshToken++;
          promptAction.showToast({ message: '手环已连接，并同步一条异常心率（模拟）' });
        })
      Text('演示流程：搜索设备 → 连接成功 → 同步心率。当前不调用真实蓝牙接口。')
        .fontSize(14)
        .lineHeight(21)
        .fontColor('#667085')
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder HeartRateCard() {
    Column({ space: 12 }) {
      Text('手动记录心率')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('低于 50 或高于 110 次/分钟会触发异常提醒。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#52635F')
      TextInput({ text: this.heartRate, placeholder: '例如 76' })
        .height(50)
        .fontSize(18)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.heartRate = value;
        })
      Button('保存心率')
        .width('100%')
        .height(50)
        .fontSize(18)
        .borderRadius(18)
        .backgroundColor('#0B7A5B')
        .onClick(() => this.saveHeartRate())
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoutineMetricCard() {
    Column({ space: 12 }) {
      Text('血压与血糖')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      TextInput({ text: this.bloodPressure, placeholder: '血压，例如 130/85' })
        .height(50)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.bloodPressure = value;
        })
      TextInput({ text: this.bloodSugar, placeholder: '血糖，例如 6.2' })
        .height(50)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange((value: string) => {
          this.bloodSugar = value;
        })
      Button('保存血压血糖')
        .width('100%')
        .height(50)
        .fontSize(18)
        .borderRadius(18)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => this.saveRoutineMetric())
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder AlertCard() {
    Column({ space: 8 }) {
      Text('异常记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(healthAlerts.length > 0 ? '#B42318' : '#0B7A5B')
      Text(healthAlerts.length > 0 ? healthAlerts[0].title + '：' + healthAlerts[0].value + '，已提醒监护人。' : '当前没有异常生命体征。')
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

  @Builder MetricRow(item: HealthMetric) {
    Row() {
      Column({ space: 5 }) {
        Text(item.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.time)
          .fontSize(14)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Column({ space: 4 }) {
        Text(item.value)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.normal ? '#0B7A5B' : '#B42318')
        Text(item.normal ? '正常' : '异常')
          .fontSize(14)
          .fontColor(item.normal ? '#0B7A5B' : '#B42318')
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor(item.normal ? '#FFFFFF' : '#FFF1F0')
  }

  @Builder SectionTitle(title: string) {
    Text(title)
      .fontSize(22)
      .fontWeight(FontWeight.Bold)
      .fontColor('#14213D')
      .width('100%')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
      Blank()
      Button('返回')
        .height(40)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#FFFFFF')
        .onClick(() => router.back())
    }
    .width('100%')
  }
}
