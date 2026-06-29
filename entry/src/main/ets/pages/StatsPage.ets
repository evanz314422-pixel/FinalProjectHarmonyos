import { router } from '@kit.ArkUI';

@Entry
@Component
struct StatsPage {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('统计分析')
        this.StatCard('本周服药完成率', '86%', 86, '#0E7C66')
        this.StatCard('连续按时天数', '5天', 70, '#2E90FA')
        this.StatCard('本月漏服次数', '3次', 30, '#F79009')
        Grid() {
          GridItem() { this.SmallMetric('今日任务', '4次') }
          GridItem() { this.SmallMetric('已完成', '2次') }
          GridItem() { this.SmallMetric('低库存', '1种') }
          GridItem() { this.SmallMetric('家属提醒', '1次') }
        }.columnsTemplate('1fr 1fr').columnsGap(12).rowsGap(12)
      }.padding(18)
    }.backgroundColor('#F4F7FA')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title).fontSize(26).fontWeight(FontWeight.Bold)
      Blank()
      Button('返回').onClick(() => router.back())
    }.width('100%')
  }

  @Builder StatCard(title: string, value: string, progress: number, color: string) {
    Column({ space: 10 }) {
      Text(title).fontSize(16).fontColor('#667085')
      Text(value).fontSize(30).fontWeight(FontWeight.Bold).fontColor(color)
      Progress({ value: progress, total: 100, type: ProgressType.Linear }).color(color).width('100%')
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF').alignItems(HorizontalAlign.Start)
  }

  @Builder SmallMetric(title: string, value: string) {
    Column({ space: 6 }) {
      Text(value).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#14213D')
      Text(title).fontSize(14).fontColor('#667085')
    }.height(92).padding(12).borderRadius(14).backgroundColor('#FFFFFF').justifyContent(FlexAlign.Center)
  }
}
