import { router } from '@kit.ArkUI';

@Entry
@Component
struct MedicineDetailPage {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('药品详情')
        Column({ space: 12 }) {
          Text('二甲双胍片').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#14213D')
          Text('规格：0.5g x 30片').fontSize(16)
          Text('常用剂量：每次 1 片，每日 3 次').fontSize(16)
          Divider()
          Text('用药说明').fontSize(20).fontWeight(FontWeight.Bold)
          Text('适用于 2 型糖尿病的血糖控制。建议餐后服用，减少胃肠道不适。服药期间需规律监测血糖。')
            .fontSize(16)
            .lineHeight(24)
          Text('注意事项').fontSize(20).fontWeight(FontWeight.Bold)
          Text('若出现明显乏力、出冷汗、心慌等低血糖表现，应及时补充糖分并联系医生。')
            .fontSize(16)
            .lineHeight(24)
        }
        .width('100%')
        .padding(18)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
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
}
