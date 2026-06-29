import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CheckInPage {
  @State status: string = '待选择';

  build() {
    Column({ space: 18 }) {
      this.Header('服药打卡')
      Column({ space: 12 }) {
        Text('当前任务').fontSize(18).fontColor('#667085')
        Text('二甲双胍片  1片').fontSize(28).fontWeight(FontWeight.Bold)
        Text('状态：' + this.status).fontSize(18).fontColor('#0E7C66')
      }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
      Button('已服用').width('100%').height(50).backgroundColor('#0E7C66')
        .onClick(() => { this.status = '已服用'; promptAction.showToast({ message: '打卡成功' }); })
      Button('稍后服用').width('100%').height(50).backgroundColor('#F79009')
        .onClick(() => { this.status = '稍后服用'; })
      Button('标记漏服').width('100%').height(50).backgroundColor('#B42318')
        .onClick(() => { this.status = '漏服'; })
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
