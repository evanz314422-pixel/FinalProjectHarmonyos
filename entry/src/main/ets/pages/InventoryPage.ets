import { router } from '@kit.ArkUI';
import { getMedicinePhotoColor, getMedicinePhotoLabel, getMedicinePhotoUri, isMedicinePhotoUploaded, Medicine, medicines } from '../models/AppData';

@Entry
@Component
struct InventoryPage {
  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('库存管理')
        ForEach(medicines, (item: Medicine) => {
          Column({ space: 8 }) {
            Row({ space: 12 }) {
              this.MedicinePhoto(item.name, 54)
              Column({ space: 4 }) {
                Text(item.name).fontSize(19).fontWeight(FontWeight.Bold)
                Text('剩余 ' + item.stock + '，低于 ' + item.threshold + ' 时提醒').fontSize(14).fontColor('#667085')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text(item.stock <= item.threshold ? '库存不足' : '库存正常')
                .fontColor(item.stock <= item.threshold ? '#B42318' : '#0E7C66')
            }.width('100%')
            Progress({ value: item.stock, total: 30, type: ProgressType.Linear })
              .color(item.stock <= item.threshold ? '#B42318' : '#0E7C66')
              .width('100%')
          }.width('100%').padding(16).borderRadius(14).backgroundColor('#FFFFFF')
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
        Image(getMedicinePhotoUri(name)).width(size).height(size).borderRadius(15).objectFit(ImageFit.Cover)
      } else {
        Column({ space: 3 }) {
          Text(getMedicinePhotoLabel(name)).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#102A27').maxLines(1)
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
    .borderRadius(15)
    .backgroundColor(getMedicinePhotoColor(name))
    .border({ width: 2, color: '#FFFFFF' })
  }
}
