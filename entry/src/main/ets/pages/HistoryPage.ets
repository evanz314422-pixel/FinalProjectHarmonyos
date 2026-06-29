import { router } from '@kit.ArkUI';
import { MedicationRecord, historyRecords } from '../models/AppData';

@Entry
@Component
struct HistoryPage {
  @State filter: string = '全部';

  private shouldShow(item: MedicationRecord): boolean {
    if (this.filter === '全部') {
      return true;
    }
    return item.status === this.filter;
  }

  private statusColor(status: string): string {
    if (status === '漏服') {
      return '#B42318';
    }
    if (status === '延迟服用') {
      return '#D97706';
    }
    return '#0E7C66';
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('历史记录')
        Text('查看已服、漏服和延迟服用情况，帮助判断哪段时间更需要提醒。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor('#52635F')
        Row({ space: 8 }) {
          this.FilterChip('全部')
          this.FilterChip('已服用')
          this.FilterChip('漏服')
          this.FilterChip('延迟服用')
        }
        .width('100%')
        ForEach(historyRecords, (item: MedicationRecord) => {
          if (this.shouldShow(item)) {
            this.RecordCard(item)
          }
        }, (item: MedicationRecord) => item.time + item.medicineName)
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
      Blank()
      Button('返回')
        .height(42)
        .fontSize(17)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .fontColor('#0B7A5B')
        .onClick(() => router.back())
    }
    .width('100%')
  }

  @Builder FilterChip(label: string) {
    Text(label)
      .fontSize(15)
      .fontWeight(this.filter === label ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.filter === label ? '#0B7A5B' : '#52635F')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(42)
      .borderRadius(16)
      .backgroundColor(this.filter === label ? '#E7F5EF' : '#FFFFFF')
      .onClick(() => {
        this.filter = label;
      })
  }

  @Builder RecordCard(item: MedicationRecord) {
    Row() {
      Column({ space: 5 }) {
        Text(item.time)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(item.medicineName)
          .fontSize(16)
          .fontColor('#52635F')
        Text(item.status === '漏服' ? '建议复盘该时间段提醒是否足够。' : '记录来源：本地模拟服药记录。')
          .fontSize(13)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text(item.status)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.statusColor(item.status))
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(14)
        .backgroundColor(item.status === '漏服' ? '#FFF1F0' : '#E7F5EF')
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
  }
}
