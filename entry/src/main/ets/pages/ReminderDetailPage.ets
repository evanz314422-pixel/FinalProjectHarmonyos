import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ReminderDetailPage {
  build() {
    Column({ space: 18 }) {
      this.Header('今日提醒详情')
      Column({ space: 14 }) {
        Text('12:30').fontSize(42).fontWeight(FontWeight.Bold).fontColor('#0E7C66')
        Text('二甲双胍片').fontSize(26).fontWeight(FontWeight.Bold)
        Text('剂量：1片  |  餐后服用').fontSize(17).fontColor('#667085')
        Progress({ value: 50, total: 100, type: ProgressType.Linear }).width('100%').color('#0E7C66')
        Text('今日已完成 2/4 次').fontSize(15).fontColor('#667085')
        Button('已按时服用').width('100%').height(48).backgroundColor('#0E7C66')
          .onClick(() => promptAction.showToast({ message: '已记录为按时服用' }))
        Button('稍后提醒').width('100%').onClick(() => promptAction.showToast({ message: '10 分钟后再次提醒（模拟）' }))
      }
      .width('100%')
      .padding(20)
      .borderRadius(18)
      .backgroundColor('#FFFFFF')
    }
    .padding(18)
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FA')
  }

  @Builder Header(title: string) {
    Row() {
      Text(title).fontSize(26).fontWeight(FontWeight.Bold)
      Blank()
      Button('返回').onClick(() => router.back())
    }.width('100%')
  }
}
