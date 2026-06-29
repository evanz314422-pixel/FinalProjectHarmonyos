import { router } from '@kit.ArkUI';
import { getMedicinePhotoColor, getMedicinePhotoLabel, getMedicinePhotoUri, isMedicinePhotoUploaded } from '../models/AppData';

@Entry
@Component
struct MedicineDetailPage {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('药品详情')
        Column({ space: 12 }) {
          Row({ space: 14 }) {
            this.MedicinePhoto('二甲双胍片', 82)
            Column({ space: 6 }) {
              Text('二甲双胍片').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#14213D')
              Text('老人端会显示此药品图片，方便看图认药。').fontSize(14).fontColor('#667085')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
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

  @Builder MedicinePhoto(name: string, size: number) {
    Stack() {
      if (getMedicinePhotoUri(name) !== '') {
        Image(getMedicinePhotoUri(name)).width(size).height(size).borderRadius(22).objectFit(ImageFit.Cover)
      } else {
        Column({ space: 3 }) {
          Text(getMedicinePhotoLabel(name)).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#102A27').maxLines(1)
          Text(isMedicinePhotoUploaded(name) ? '药图' : '待传').fontSize(11).fontColor('#0B7A5B')
        }
        .width(size)
        .height(size)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width(size)
    .height(size)
    .borderRadius(22)
    .backgroundColor(getMedicinePhotoColor(name))
    .border({ width: 2, color: '#FFFFFF' })
  }
}
