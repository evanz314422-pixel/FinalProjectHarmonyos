import { router } from '@kit.ArkUI';
import { getElderHistoryRecords, MedicationRecord } from '../models/AppData';

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

  private visibleDates(): string[] {
    const dates: string[] = [];
    const records: MedicationRecord[] = getElderHistoryRecords();
    for (let index = 0; index < records.length; index++) {
      if (this.shouldShow(records[index])) {
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
    Scroll() {
      Column({ space: 16 }) {
        this.Header('记录与趋势')
        Row({ space: 8 }) {
          this.FilterChip('全部')
          this.FilterChip('已服用')
          this.FilterChip('漏服')
          this.FilterChip('延迟服用')
        }
        .width('100%')
        this.HistorySummaryCard()
        Text('历史记录（按日期）')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
          .width('100%')
        ForEach(this.visibleDates(), (dateText: string) => {
          this.DateGroup(dateText)
        }, (dateText: string) => dateText + this.filter)
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
        Text('记录来源：' + (item.source === undefined ? '系统未响应' : item.source))
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

  @Builder DateGroup(dateText: string) {
    Column({ space: 12 }) {
      Text(dateText)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
        .width('100%')
      ForEach(getElderHistoryRecords(), (item: MedicationRecord) => {
        if (this.shouldShow(item) && this.recordDateText(item) === dateText) {
          this.RecordLine(item)
        }
      }, (item: MedicationRecord) => item.time + item.medicineName + item.status + this.filter)
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RecordLine(item: MedicationRecord) {
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
      Text(item.status)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.statusColor(item.status))
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(14)
        .backgroundColor(item.status === '漏服' ? '#FFF1F0' : item.status === '延迟服用' ? '#FFF7E8' : '#E7F5EF')
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder HistorySummaryCard() {
    Row({ space: 10 }) {
      this.HistoryMetric('全部', getElderHistoryRecords().length.toString())
      this.HistoryMetric('漏服', this.countStatus('漏服').toString())
      this.HistoryMetric('延迟', this.countStatus('延迟服用').toString())
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
  }

  @Builder HistoryMetric(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(label === '漏服' ? '#B42318' : label === '延迟' ? '#D97706' : '#0B7A5B')
      Text(label)
        .fontSize(14)
        .fontColor('#52635F')
    }
    .layoutWeight(1)
    .height(62)
    .justifyContent(FlexAlign.Center)
  }

  private countStatus(status: string): number {
    let count: number = 0;
    const list: MedicationRecord[] = getElderHistoryRecords();
    for (let index = 0; index < list.length; index++) {
      if (list[index].status === status) {
        count++;
      }
    }
    return count;
  }
}
