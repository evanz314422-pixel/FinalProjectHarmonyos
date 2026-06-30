import { router, promptAction } from '@kit.ArkUI';
import { FamilyBinding, familyBindings, selectElder, UserRole, setSession } from '../models/AppData';

type AuthStep = 'login' | 'chooseRole' | 'bindElder';

@Entry
@Component
struct LoginPage {
  @State authStep: AuthStep = 'login';
  @State selectedRole: UserRole = 'elder';
  @State phone: string = '';
  @State code: string = '';
  @State bindCode: string = '';

  private isValidPhone(): boolean {
    if (this.phone.length !== 11) {
      return false;
    }
    if (!this.phone.startsWith('1')) {
      return false;
    }
    for (let index = 0; index < this.phone.length; index++) {
      const code: number = this.phone.charCodeAt(index);
      if (code < 48 || code > 57) {
        return false;
      }
    }
    return true;
  }

  private isValidCode(): boolean {
    if (this.code.length !== 6) {
      return false;
    }
    for (let index = 0; index < this.code.length; index++) {
      const code: number = this.code.charCodeAt(index);
      if (code < 48 || code > 57) {
        return false;
      }
    }
    return true;
  }

  private requestCode(): void {
    if (!this.isValidPhone()) {
      promptAction.showToast({ message: '请输入正确的11位手机号' });
      return;
    }
    promptAction.showToast({ message: '验证码已发送' });
  }

  private continueAfterLogin(): void {
    if (!this.isValidPhone()) {
      promptAction.showToast({ message: '请输入正确的11位手机号' });
      return;
    }
    if (!this.isValidCode()) {
      promptAction.showToast({ message: '请输入6位数字验证码' });
      return;
    }
    this.authStep = 'chooseRole';
    promptAction.showToast({ message: '请确认使用身份' });
  }

  private chooseRole(role: UserRole): void {
    this.selectedRole = role;
    if (role === 'elder') {
      this.enterApp('elder');
    } else {
      this.authStep = 'bindElder';
    }
  }

  private enterApp(role: UserRole): void {
    setSession(role);
    promptAction.showToast({ message: role === 'elder' ? '已进入老人端' : '已进入家属端' });
    router.replaceUrl({ url: 'pages/Index' });
  }

  private submitBind(): void {
    for (let index = 0; index < familyBindings.length; index++) {
      const item: FamilyBinding = familyBindings[index];
      if (this.bindCode === item.code) {
        selectElder(item.elderId);
        promptAction.showToast({ message: '绑定成功' });
        this.enterApp('guardian');
        return;
      }
    }
    promptAction.showToast({ message: '绑定码不正确，请核对后重试' });
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        this.BrandHeader()
        if (this.authStep === 'login') {
          this.LoginPanel()
        } else if (this.authStep === 'chooseRole') {
          this.RolePanel()
        } else {
          this.BindPanel()
        }
      }
      .padding({ left: 22, right: 22, top: 48, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB')
  }

  @Builder BrandHeader() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        this.UsagePill('用药提醒', '#0B7A5B', '#E7F5EF')
        this.UsagePill('家属看护', '#155EEF', '#EAF2FF')
      }
      .width('100%')
      Text('安心服药助手')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#102A27')
      Text('老人按时服药，家属及时看护')
        .fontSize(19)
        .lineHeight(27)
        .fontColor('#52635F')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder LoginPanel() {
    Column({ space: 16 }) {
      Text('手机号登录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14213D')

      this.InputField('手机号', '请输入手机号', this.phone, (value: string) => {
        this.phone = value;
      })
      this.CodeField()

      Button('登录并继续')
        .width('100%')
        .height(58)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .borderRadius(22)
        .backgroundColor('#0B7A5B')
        .onClick(() => this.continueAfterLogin())
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RolePanel() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .height(40)
          .fontSize(16)
          .borderRadius(16)
          .fontColor('#0B7A5B')
          .backgroundColor('#E7F5EF')
          .onClick(() => {
            this.authStep = 'login';
          })
        Blank()
        Text('完善身份')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
      }
      .width('100%')

      Text('你是本人使用，还是帮助家人看护？')
        .fontSize(18)
        .lineHeight(26)
        .fontColor('#52635F')

      this.RoleChoice('本人使用', '查看今日服药，一键确认已吃药。', 'elder', true)
      this.RoleChoice('我是家属', '绑定老人账号，查看服药和健康异常。', 'guardian', false)
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BindPanel() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .height(40)
          .fontSize(16)
          .borderRadius(16)
          .fontColor('#0B7A5B')
          .backgroundColor('#E7F5EF')
          .onClick(() => {
            this.authStep = 'chooseRole';
          })
        Blank()
        Text('绑定老人账号')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
      }
      .width('100%')
      Text('请输入老人手机上“我的”页面显示的绑定码。')
        .fontSize(17)
        .lineHeight(25)
        .fontColor('#52635F')
      this.InputField('绑定码', '请输入绑定码', this.bindCode, (value: string) => {
        this.bindCode = value;
      })
      Button('完成绑定并进入')
        .width('100%')
        .height(58)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .borderRadius(22)
        .backgroundColor('#0B7A5B')
        .onClick(() => this.submitBind())
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder RoleChoice(title: string, desc: string, role: UserRole, primary: boolean) {
    Row({ space: 12 }) {
      Column({ space: 5 }) {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14213D')
        Text(desc)
          .fontSize(15)
          .lineHeight(22)
          .fontColor('#667085')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('进入')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(primary ? '#0B7A5B' : '#155EEF')
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor(primary ? '#E7F5EF' : '#EAF2FF')
    .onClick(() => this.chooseRole(role))
  }

  @Builder UsagePill(text: string, color: string, bgColor: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(14)
      .backgroundColor(bgColor)
  }

  @Builder CodeField() {
    Row({ space: 10 }) {
      Column({ space: 8 }) {
        Text('验证码')
          .fontSize(16)
          .fontColor('#52635F')
        TextInput({ text: this.code, placeholder: '6 位验证码' })
          .height(50)
          .fontSize(18)
          .borderRadius(16)
          .backgroundColor('#F6F8F7')
          .onChange((value: string) => {
            this.code = value;
          })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button('获取验证码')
        .height(50)
        .fontSize(16)
        .borderRadius(16)
        .fontColor('#0B7A5B')
        .backgroundColor('#E7F5EF')
        .onClick(() => this.requestCode())
    }
    .width('100%')
  }

  @Builder InputField(label: string, placeholder: string, value: string, change: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(16)
        .fontColor('#52635F')
      TextInput({ text: value, placeholder: placeholder })
        .height(50)
        .fontSize(18)
        .borderRadius(16)
        .backgroundColor('#F6F8F7')
        .onChange(change)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
