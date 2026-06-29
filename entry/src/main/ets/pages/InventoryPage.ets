import { router } from '@kit.ArkUI';
import { Medicine, medicines } from '../models/AppData';

@Entry
@Component
struct InventoryPage {
  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('库存管理')
        ForEach(medicines, (item: Medicine) => {
          Column({ space: 8 }) {
            Row() {
              Text(item.name).fontSize(19).fontWeight(FontWeight.Bold)
              Blank()
              Text(item.stock <= item.threshold ? '库存不足' : '库存正常')
                .fontColor(item.stock <= item.threshold ? '#B42318' : '#0E7C66')
            }.width('100%')
            Text('剩余 ' + item.stock + '，低于 ' + item.threshold + ' 时提醒').fontSize(14).fontColor('#667085')
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
}
