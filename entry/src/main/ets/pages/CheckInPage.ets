import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CheckInPage {
  @State status: string = '待选择';

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.Header('补记服药状态')
        Column({ space: 12 }) {
          Text('当前需要补记')
            .fontSize(18)
            .fontColor('#667085')
          Text('二甲双胍片  1片')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14213D')
          Text('如果刚刚已经在首页确认过，就不用重复操作。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#52635F')
          Text('状态：' + this.status)
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.status === '漏服' ? '#B42318' : '#0B7A5B')
        }
        .width('100%')
        .padding(20)
        .borderRadius(22)
        .backgroundColor('#FFFFFF')
        .alignItems(HorizontalAlign.Start)

        Button('现在已服用')
          .width('100%')
          .height(56)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .backgroundColor('#0E7C66')
          .onClick(() => {
            this.status = '已服用';
            promptAction.showToast({ message: '已补记为已服用' });
          })
        Button('10 分钟后提醒')
          .width('100%')
          .height(56)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .backgroundColor('#F79009')
          .onClick(() => {
            this.status = '稍后提醒';
            promptAction.showToast({ message: '10 分钟后再次提醒（模拟）' });
          })
        Button('今天漏服了')
          .width('100%')
          .height(56)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(18)
          .backgroundColor('#B42318')
          .onClick(() => {
            this.status = '漏服';
            promptAction.showToast({ message: '已记录漏服，建议联系家属确认' });
          })
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
        .fontColor('#0B7A5B')
        .backgroundColor('#FFFFFF')
        .onClick(() => router.back())
    }
    .width('100%')
  }
}
