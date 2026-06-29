import { router } from '@kit.ArkUI';
import { getMedicinePhotoColor, getMedicinePhotoLabel, getMedicinePhotoUri, isMedicinePhotoUploaded, Medicine, medicines } from '../models/AppData';

@Entry
@Component
struct MedicineLibraryPage {
  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('药品库')
        Button('+ 新增药品').width('100%').onClick(() => router.pushUrl({ url: 'pages/AddMedicinePage' }))
        ForEach(medicines, (item: Medicine) => {
          Row({ space: 12 }) {
            this.MedicinePhoto(item.name, 58)
            Column({ space: 5 }) {
              Text(item.name).fontSize(20).fontWeight(FontWeight.Bold)
              Text(item.spec + '  默认剂量：' + item.dosage).fontSize(14).fontColor('#667085')
              Text('库存 ' + item.stock + '，预警阈值 ' + item.threshold).fontSize(14).fontColor(item.stock <= item.threshold ? '#B42318' : '#0E7C66')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Text('详情').fontColor('#0E7C66')
          }
          .width('100%')
          .padding(16)
          .borderRadius(14)
          .backgroundColor('#FFFFFF')
          .onClick(() => router.pushUrl({ url: 'pages/MedicineDetailPage' }))
        }, (item: Medicine) => item.id.toString())
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
        Image(getMedicinePhotoUri(name)).width(size).height(size).borderRadius(16).objectFit(ImageFit.Cover)
      } else {
        Column({ space: 3 }) {
          Text(getMedicinePhotoLabel(name)).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#102A27').maxLines(1)
          Text(isMedicinePhotoUploaded(name) ? '药图' : '待传').fontSize(9).fontColor('#0B7A5B')
        }
        .width(size)
        .height(size)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width(size)
    .height(size)
    .borderRadius(16)
    .backgroundColor(getMedicinePhotoColor(name))
    .border({ width: 2, color: '#FFFFFF' })
  }
}
