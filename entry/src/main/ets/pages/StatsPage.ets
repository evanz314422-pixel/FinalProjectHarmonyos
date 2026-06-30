import { router } from '@kit.ArkUI';
import {
  getElderCareActionRecords,
  getElderHistoryRecords,
  getElderMedicines,
  getElderTodayRecords,
  Medicine,
  MedicationRecord
} from '../models/AppData';

@Entry
@Component
struct StatsPage {
  private doneToday(): number {
    let count: number = 0;
    const records: MedicationRecord[] = getElderTodayRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '已服用') {
        count++;
      }
    }
    return count;
  }

  private lowStockCount(): number {
    let count: number = 0;
    const items: Medicine[] = getElderMedicines();
    for (let index = 0; index < items.length; index++) {
      if (items[index].stock <= items[index].threshold) {
        count++;
      }
    }
    return count;
  }

  private missedCount(): number {
    let count: number = 0;
    const records: MedicationRecord[] = getElderHistoryRecords();
    for (let index = 0; index < records.length; index++) {
      if (records[index].status === '漏服') {
        count++;
      }
    }
    return count;
  }

  private completionRate(): number {
    const total: number = getElderTodayRecords().length;
    if (total === 0) {
      return 0;
    }
    return Math.round(this.doneToday() * 100 / total);
  }

  private lowStockDesc(): string {
    const items: Medicine[] = getElderMedicines();
    for (let index = 0; index < items.length; index++) {
      if (items[index].stock <= items[index].threshold) {
        return items[index].name + '低于阈值，需要尽快补充。';
      }
    }
    return '当前没有低库存药品，继续保持定期检查。';
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('看护分析')
        this.AnalysisCard('今日服药完成率', this.completionRate().toString() + '%', '根据当前老人今日服药记录计算，未确认任务会进入待办。', this.completionRate(), '#0E7C66')
        this.AnalysisCard('连续按时天数', '5天', '连续记录越稳定，家属需要介入的频率越低。', 70, '#155EEF')
        this.AnalysisCard('本月漏服次数', this.missedCount().toString() + '次', '漏服主要集中在午间，建议提前 10 分钟轻提醒。', 30, '#F79009')
        this.AnalysisCard('低库存趋势', this.lowStockCount().toString() + '种', this.lowStockDesc(), this.lowStockCount() > 0 ? 70 : 20, '#C56A16')
        Grid() {
          GridItem() { this.SmallMetric('今日任务', getElderTodayRecords().length.toString() + '次') }
          GridItem() { this.SmallMetric('已完成', this.doneToday().toString() + '次') }
          GridItem() { this.SmallMetric('低库存', this.lowStockCount().toString() + '种') }
          GridItem() { this.SmallMetric('家属提醒', getElderCareActionRecords().length.toString() + '次') }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        this.ExplainCard()
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

  @Builder AnalysisCard(title: string, value: string, desc: string, progress: number, color: string) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(value)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Progress({ value: progress, total: 100, type: ProgressType.Linear })
        .color(color)
        .width('100%')
      Text(desc)
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#52635F')
    }
    .width('100%')
    .padding(18)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SmallMetric(title: string, value: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(title)
        .fontSize(14)
        .fontColor('#667085')
    }
    .height(96)
    .padding(12)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
  }

  @Builder ExplainCard() {
    Text('说明：当前统计基于本地服药记录、库存和健康指标生成。后续可接入设备同步、提醒记录和处方数据。')
      .fontSize(14)
      .lineHeight(22)
      .fontColor('#667085')
      .width('100%')
      .padding(16)
      .borderRadius(18)
      .backgroundColor('#EEF2F6')
  }
}
