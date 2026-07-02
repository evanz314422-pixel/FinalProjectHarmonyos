import { router, promptAction } from '@kit.ArkUI';
import { addCareActionRecord, addRefillTodo, getElderMedicines, getMedicinePhotoColor, getMedicinePhotoLabel, getMedicinePhotoUri, isMedicinePhotoUploaded, Medicine } from '../models/AppData';

@Entry
@Component
struct InventoryPage {
  @State refreshToken: number = 0;

  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.Header('库存管理')
        ForEach(getElderMedicines(), (item: Medicine) => {
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
            if (item.stock <= item.threshold) {
              Button(item.refillArranged ? '已安排补药' : '安排补药')
                .width('100%')
                .height(42)
                .fontSize(16)
                .borderRadius(15)
                .backgroundColor(item.refillArranged ? '#98A2B3' : '#0B7A5B')
                .onClick(() => {
                  if (item.refillArranged) {
                    promptAction.showToast({ message: '这项补药已经安排过了' });
                    return;
                  }
                  addRefillTodo(item.name);
                  addCareActionRecord('安排补药', item.name + '库存不足，已记录补药安排。', '家属处理');
                  this.refreshToken++;
                  promptAction.showToast({ message: '已安排补药' });
                })
            }
          }.width('100%').padding(16).borderRadius(14).backgroundColor('#FFFFFF')
        }, (item: Medicine) => item.id.toString() + (item.refillArranged ? 'done' : 'open') + this.refreshToken.toString())
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
