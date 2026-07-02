import { router, promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { addMedicineForElder, currentSession, selectMedicine, startCreatePlanForMedicine } from '../models/AppData';

@Entry
@Component
struct AddMedicinePage {
  @State name: string = '';
  @State spec: string = '';
  @State dosage: string = '';
  @State stock: string = '';
  @State note: string = '';
  @State aiRecognized: boolean = false;
  @State recognizing: boolean = false;
  @State photoUri: string = '';
  @State photoUploaded: boolean = false;
  @State photoLabel: string = '药品';
  @State photoColor: string = '#E7F5EF';
  @State saved: boolean = false;
  @State savedMedicineName: string = '';
  @State createdMedicine: boolean = true;

  private fillRecognizedMedicine(): void {
    this.name = '硝苯地平控释片';
    this.spec = '30mg x 7片';
    this.dosage = '1片';
    this.stock = '7';
    this.note = '拍照识别：常用于血压管理。建议每日固定时间服用，具体用法请以医生处方为准。';
    this.photoUri = '';
    this.photoUploaded = true;
    this.photoLabel = '降压';
    this.photoColor = '#FFF7E8';
  }

  private updatePhotoLabelFromName(): void {
    const sourceName: string = this.name === '' ? '药品' : this.name;
    this.photoLabel = sourceName.length >= 2 ? sourceName.substring(0, 2) : sourceName;
  }

  private isIntegerText(value: string): boolean {
    if (value === '') {
      return true;
    }
    for (let index = 0; index < value.length; index++) {
      const char: string = value.charAt(index);
      if (char < '0' || char > '9') {
        return false;
      }
    }
    return true;
  }

  private goCreatePlan(): void {
    startCreatePlanForMedicine(this.savedMedicineName);
    router.pushUrl({ url: 'pages/AddPlanPage' });
  }

  private selectMedicinePhoto(): void {
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const picker = new photoAccessHelper.PhotoViewPicker();
    picker.select(options).then((result: photoAccessHelper.PhotoSelectResult) => {
      if (result.photoUris.length > 0) {
        this.photoUri = result.photoUris[0];
        this.photoUploaded = true;
        this.updatePhotoLabelFromName();
        this.photoColor = this.name === '硝苯地平控释片' ? '#FFF7E8' : '#E7F5EF';
        promptAction.showToast({ message: '已选择药品照片' });
      }
    }).catch(() => {
      promptAction.showToast({ message: '未选择照片' });
    });
  }

  private saveMedicine(): void {
    const stockValue: number = this.stock === '' ? 0 : Number(this.stock);
    if (this.name === '') {
      promptAction.showToast({ message: '请填写药品名称' });
      return;
    }
    if (!this.isIntegerText(this.stock) || stockValue < 0) {
      promptAction.showToast({ message: '请输入正确库存数量' });
      return;
    }
    const created: boolean = addMedicineForElder(this.name, this.spec, this.dosage, stockValue, this.note, this.photoUri, this.photoLabel, this.photoColor, this.photoUploaded);
    selectMedicine(this.name);
    this.savedMedicineName = this.name;
    this.createdMedicine = created;
    this.saved = true;
    promptAction.showToast({ message: created ? (currentSession.role === 'guardian' ? '已替老人保存药品' : '已保存到常用药') : '已更新药品信息' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header(currentSession.role === 'guardian' ? '替老人添加药品' : '新增药品')
        this.AiCaptureCard()
        this.PhotoUploadCard()
        Button('看不懂药？去问药求助')
          .width('100%')
          .height(48)
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .fontColor('#0B7A5B')
          .onClick(() => router.pushUrl({ url: 'pages/AIAssistantPage' }))

        if (this.aiRecognized) {
          this.RecognitionResultCard()
        }

        this.Field('药品名称', '例如：二甲双胍片', this.name, (value: string) => {
          this.name = value;
          if (!this.photoUploaded) {
            this.updatePhotoLabelFromName();
          }
        })
        this.Field('规格包装', '例如：0.5g x 30片', this.spec, (value: string) => {
          this.spec = value;
        })
        this.Field('默认剂量', '例如：1片', this.dosage, (value: string) => {
          this.dosage = value;
        })
        this.Field('当前库存', '例如：30', this.stock, (value: string) => {
          this.stock = value;
        })
        this.Field('注意事项', '饭前饭后、禁忌或医生叮嘱', this.note, (value: string) => {
          this.note = value;
        })

        if (this.saved) {
          this.SavedNextStepCard()
        } else {
          Button('保存到常用药')
            .width('100%')
            .height(54)
            .fontSize(19)
            .borderRadius(20)
            .backgroundColor('#0B7A5B')
            .onClick(() => this.saveMedicine())
        }

        Text('提示：拍照识别只能辅助录入，最终药名、剂量和服用方式应由本人或监护人与医生处方核对。')
          .fontSize(13)
          .lineHeight(20)
          .fontColor('#667085')
          .width('100%')
      }
      .padding(18)
    }
    .backgroundColor('#F5F7FA')
    .width('100%')
    .height('100%')
  }

  @Builder Header(title: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text('拍照识别或手动录入药品信息')
          .fontSize(15)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回')
        .height(40)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .fontColor('#0B7A5B')
        .onClick(() => router.back())
    }
    .width('100%')
  }

  @Builder AiCaptureCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 6 }) {
          Text('拍照识别药品')
            .fontSize(21)
            .fontWeight(FontWeight.Bold)
            .fontColor('#102A27')
          Text('适合看不清药名、不方便打字时快速录入')
            .fontSize(14)
            .fontColor('#667085')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text('拍照')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(44)
          .height(44)
          .textAlign(TextAlign.Center)
          .borderRadius(14)
          .backgroundColor('#0B7A5B')
      }
      .width('100%')

      Row({ space: 10 }) {
        Button(this.recognizing ? '识别中...' : '拍照识别')
          .layoutWeight(1)
          .height(48)
          .borderRadius(18)
          .backgroundColor('#0B7A5B')
          .onClick(() => {
            this.recognizing = true;
            this.fillRecognizedMedicine();
            this.aiRecognized = true;
            this.recognizing = false;
            promptAction.showToast({ message: '已识别药盒文字，请确认后保存' });
          })

        Button('相册导入')
          .layoutWeight(1)
          .height(48)
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .fontColor('#0B7A5B')
          .onClick(() => {
            this.fillRecognizedMedicine();
            this.aiRecognized = true;
            promptAction.showToast({ message: '已从相册识别药品' });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#E7F5EF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PhotoUploadCard() {
    Row({ space: 14 }) {
      Stack() {
        if (this.photoUri !== '') {
          Image(this.photoUri)
            .width(76)
            .height(76)
            .borderRadius(20)
            .objectFit(ImageFit.Cover)
        } else {
          Column({ space: 4 }) {
            Text(this.photoLabel)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#102A27')
              .maxLines(1)
            Text(this.photoUploaded ? '已上传' : '待上传')
              .fontSize(11)
              .fontColor('#0B7A5B')
          }
          .width(76)
          .height(76)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width(76)
      .height(76)
      .borderRadius(20)
      .backgroundColor(this.photoColor)
      .border({ width: 2, color: '#FFFFFF' })

      Column({ space: 8 }) {
        Text('药盒照片')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(this.photoUploaded ? '保存后会显示在老人端药品名称旁，方便看图认药。' : '可以上传药盒或药板照片，防止老人看不清药名。')
          .fontSize(14)
          .lineHeight(21)
          .fontColor('#667085')
        Row({ space: 8 }) {
          Button(this.photoUploaded ? '重新上传' : '上传照片')
            .layoutWeight(1)
            .height(42)
            .borderRadius(16)
            .backgroundColor('#0B7A5B')
            .onClick(() => this.selectMedicinePhoto())
          Button('用药名生成')
            .layoutWeight(1)
            .height(42)
            .borderRadius(16)
            .fontColor('#0B7A5B')
            .backgroundColor('#FFFFFF')
            .onClick(() => {
              this.photoUri = '';
              this.photoUploaded = false;
              this.updatePhotoLabelFromName();
              promptAction.showToast({ message: '已用药名生成临时识别图' });
            })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  @Builder RecognitionResultCard() {
    Column({ space: 10 }) {
      Row() {
        Text('识别结果待确认')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Blank()
        Text('可信度 92%')
          .fontSize(13)
          .fontColor('#0B7A5B')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(12)
          .backgroundColor('#EAF7F1')
      }
      .width('100%')

      Text('识别到：硝苯地平控释片，30mg x 7片。系统已自动填入下方表单，并生成药盒图片标识。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#475467')

      Row({ space: 10 }) {
        Button('重新识别')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#FFFFFF')
          .fontColor('#0B7A5B')
          .onClick(() => {
            this.recognizing = true;
            this.fillRecognizedMedicine();
            this.recognizing = false;
            promptAction.showToast({ message: '已重新识别药盒文字' });
          })
        Button('确认无误')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#0B7A5B')
          .onClick(() => {
            this.aiRecognized = false;
            promptAction.showToast({ message: '已确认识别结果' });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SavedNextStepCard() {
    Column({ space: 12 }) {
      Text(this.createdMedicine ? '药品已保存' : '药品已更新')
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text('接下来可以为“' + this.savedMedicineName + '”设置服药时间。设置后，它会自动出现在今日服药监督和服药追踪里。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#52635F')
      Row({ space: 10 }) {
        Button('设置服药计划')
          .layoutWeight(1)
          .height(48)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .backgroundColor('#0B7A5B')
          .onClick(() => this.goCreatePlan())
        Button('返回药品页')
          .layoutWeight(1)
          .height(48)
          .fontSize(17)
          .borderRadius(16)
          .fontColor('#0B7A5B')
          .backgroundColor('#E7F5EF')
          .onClick(() => router.back())
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder Field(label: string, placeholder: string, value: string, change: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(15)
        .fontColor('#667085')
      TextInput({ text: value, placeholder: placeholder })
        .height(50)
        .fontSize(17)
        .borderRadius(14)
        .backgroundColor('#F9FAFB')
        .onChange(change)
    }
    .width('100%')
    .padding(14)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }
}
