import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct AIAssistantPage {
  @State helpResult: string = '不确定时不要自己加量或停药，先按医生处方来。';
  @State voiceText: string = '';

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.Header()
        this.PhotoHelpCard()
        this.VoiceCard()
        this.FamilyHelpCard()
        this.SafetyNote()
      }
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder Header() {
    Row() {
      Column({ space: 6 }) {
        Text('问药求助')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text('看不清、不会问，就拍照或说话')
          .fontSize(17)
          .lineHeight(24)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回')
        .height(38)
        .backgroundColor('#FFFFFF')
        .fontColor('#0E7C66')
        .onClick(() => router.back())
    }
    .width('100%')
  }

  @Builder PhotoHelpCard() {
    Column({ space: 12 }) {
      this.CardTitle('拍照问药', '看不清药盒时，让家属一起确认')
      Button('拍药盒照片')
        .width('100%')
        .height(60)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .borderRadius(20)
        .backgroundColor('#0B7A5B')
        .onClick(() => {
          this.helpResult = '已拍照。请让家属核对药名和吃法，不要自己加量或停药。';
          promptAction.showToast({ message: '已拍照求助' });
        })
      this.ResultBox()
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder VoiceCard() {
    Column({ space: 12 }) {
      this.CardTitle('按住说话', '不会打字也可以直接问')
      Button(this.voiceText === '' ? '按住说话' : '重新说一遍')
        .width('100%')
        .height(60)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .borderRadius(20)
        .backgroundColor('#0B7A5B')
        .onClick(() => {
          this.voiceText = '我看不清这个药，帮我看看怎么吃。';
          this.helpResult = '已记录你的问题。建议先联系家属确认，再按医生处方服用。';
          promptAction.showToast({ message: '已记录语音求助' });
        })
      Text(this.voiceText === '' ? '按住后，说出你想问的问题。' : this.voiceText)
        .fontSize(18)
        .lineHeight(26)
        .fontColor('#475467')
        .width('100%')
        .padding(14)
        .borderRadius(16)
        .backgroundColor('#F9FAFB')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder FamilyHelpCard() {
    Column({ space: 12 }) {
      this.CardTitle('联系家属', '不确定时，直接叫家属帮忙')
      Button('叫家属帮我看')
        .width('100%')
        .height(60)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .borderRadius(20)
        .backgroundColor('#155EEF')
        .onClick(() => {
          this.helpResult = '已提醒家属。等待家属确认前，请不要自行改变吃法。';
          promptAction.showToast({ message: '已提醒家属' });
        })
      Text('家属：李女士 13800000002')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
    }
    .width('100%')
    .padding(18)
    .borderRadius(22)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder SafetyNote() {
    Text('提醒：不确定时不要自己加药、减药或停药。请按医生处方，必要时让家属帮你确认。')
      .fontSize(15)
      .lineHeight(23)
      .fontColor('#667085')
      .width('100%')
      .padding(14)
      .borderRadius(16)
      .backgroundColor('#EEF2F6')
  }

  @Builder CardTitle(title: string, desc: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')
      Text(desc)
        .fontSize(16)
        .lineHeight(23)
        .fontColor('#667085')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder ResultBox() {
    Text(this.helpResult)
      .fontSize(20)
      .lineHeight(30)
      .fontWeight(FontWeight.Bold)
      .fontColor('#14213D')
      .width('100%')
      .padding(16)
      .borderRadius(18)
      .backgroundColor('#F6FEF9')
  }
}
