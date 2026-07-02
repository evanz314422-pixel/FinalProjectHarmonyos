import { router, promptAction } from '@kit.ArkUI';
import { getMedicinePhotoColor, getMedicinePhotoLabel, getMedicinePhotoUri, getMedicinePlanText, getSelectedMedicine, isMedicinePhotoUploaded, Medicine, StockUpdateResult, updateMedicineStock } from '../models/AppData';

@Entry
@Component
struct MedicineDetailPage {
  @State stockInput: string = '';
  @State refreshToken: number = 0;

  private currentMedicine(): Medicine {
    this.refreshToken;
    return getSelectedMedicine();
  }

  private saveStock(): void {
    const nextStock: number = Number(this.stockInput);
    if (!this.isIntegerText(this.stockInput) || nextStock < 0) {
      promptAction.showToast({ message: '请输入正确库存数量' });
      return;
    }
    const result: StockUpdateResult = updateMedicineStock(this.currentMedicine().name, nextStock);
    this.refreshToken++;
    if (!result.found) {
      promptAction.showToast({ message: '未找到药品' });
      return;
    }
    promptAction.showToast({ message: result.lowStock ? '库存仍低于阈值，请安排补药' : result.refillCleared ? '库存已补足，补药状态已清除' : '库存已更新' });
  }

  private isIntegerText(value: string): boolean {
    if (value === '') {
      return false;
    }
    for (let index = 0; index < value.length; index++) {
      const char: string = value.charAt(index);
      if (char < '0' || char > '9') {
        return false;
      }
    }
    return true;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header('药品详情')
        Column({ space: 12 }) {
          Row({ space: 14 }) {
            this.MedicinePhoto(this.currentMedicine().name, 82)
            Column({ space: 6 }) {
              Text(this.currentMedicine().name).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#14213D')
              Text('老人端会显示此药品图片，方便看图认药。').fontSize(14).fontColor('#667085')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          Text('规格：' + this.currentMedicine().spec).fontSize(16)
          Text('默认剂量：' + this.currentMedicine().dosage).fontSize(16)
          Text('用药计划：' + getMedicinePlanText(this.currentMedicine().name)).fontSize(16).lineHeight(24)
          Text('当前库存：' + this.currentMedicine().stock.toString() + '，低于 ' + this.currentMedicine().threshold.toString() + ' 时提醒补充。')
            .fontSize(16)
            .lineHeight(24)
          Row({ space: 10 }) {
            TextInput({ placeholder: '输入新库存', text: this.stockInput })
              .layoutWeight(1)
              .height(46)
              .fontSize(16)
              .borderRadius(14)
              .backgroundColor('#F6F8FB')
              .onChange((value: string) => {
                this.stockInput = value;
              })
            Button('更新库存')
              .height(46)
              .fontSize(15)
              .borderRadius(14)
              .backgroundColor('#0B7A5B')
              .onClick(() => this.saveStock())
          }
          .width('100%')
          Divider()
          Text('用药说明').fontSize(20).fontWeight(FontWeight.Bold)
          Text(this.currentMedicine().note)
            .fontSize(16)
            .lineHeight(24)
          Text('注意事项').fontSize(20).fontWeight(FontWeight.Bold)
          Text('药名、剂量和禁忌应以医生处方为准。如出现不适，请联系家属或医生确认。')
            .fontSize(16)
            .lineHeight(24)
          Text('数据来源').fontSize(20).fontWeight(FontWeight.Bold)
          Text('药品信息来自本人或家属录入；照片用于辅助辨认，不能替代医生处方。')
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
