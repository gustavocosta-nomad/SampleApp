export interface SignPayloadData {
  name?: string;
  [key: string]: any;
}

export interface SignPayloadRequest {
  type: 'authToken' | 'customData';
  data: SignPayloadData;
}

export interface SignPayloadResult {
  type: 'authToken' | 'customData';
  token?: string;
  error?: string;
}

export interface AndroidError {
  errorCode: number;
}

export interface SdkEvent {
  event_name: string;
  application: string;
  app_id: string;
  app_version: string;
  sdk_version: string;
  timestamp: string;
  device_mode: string;
  device_version: string;

  menu_name?: string;
  menu_id?: string;
  menu_key?: string;
  menu_path?: string;

  has_attachment?: boolean;
  type?: string;
  session_id?: string;
  end_user_identifier?: string;
  event_params?: any;
  link?: string;
  agent_name?: string;
  duration?: string;
  ended_by?: string;
}

/**
 * The `InitOption` interface is designed for configuration settings that are only applicable for iOS.
 * For Android, these settings should be included directly in the AndroidManifest.xml file.
 */
interface InitOption {
  key: string; // AndroidManifest.xml > co.ujet.android.companyKey
  baseUrl?: string; // AndroidManifest.xml > co.ujet.android.companyUrl
  subdomain?: string; // AndroidManifest.xml > co.ujet.android.subdomain
}

interface StartOption {
  menuKey?: string;
  ivrNumber?: string;
  unsignedCustomData?: CustomData;
  ticketId?: string;
  skipSplashScreen: boolean;
  preferredChannel?: 'call' | 'chat';
}

interface UJETGlobalTheme {
  ios: {
    fontSize?: number; // iOS only
    lightFontName?: string; // iOS only
    lightFontSize?: number; // iOS only
    boldFontName?: string; // iOS only
    boldFontSize?: number; // iOS only
    forceToUseWhiteTextForTintedBackgroundColor?: boolean; // iOS only
    forceToUseBlackTextForTintedBackgroundColor?: boolean; // iOS only

    companyImage?: string; // styles.xml > ujet_companyLogo
    fontName?: string; // styles.xml > ujet_typeFace
    tintColor?: string; // styles.xml > ujet_colorPrimary
    tintColorForDarkMode?: string; // styles.xml > ujet_colorPrimaryDark
    defaultAgentImage?: string; // styles.xml > ujet_defaultAvatar
    backgroundColor?: string; //styles.xml > ujet_colorBackground
    backgroundColorForDarkMode?: string; //styles.xml > ujet_colorBackgroundDark
    supportTitleLabelFontSize?: number; // dimens.xml > ujet_title
    supportDescriptionLabelFontSize?: number; // dimens.xml > ujet_description
    supportPickerViewFontSize?: number; // dimens.xml > ujet_picker_item_text_size
  };

  staticFontSizeInSupportPickerView?: boolean;
  customChatThemeJSON?: string;
}

interface UJETGlobalOptions {
  statusBarNotificationViewAlpha?: number; // iOS only
  enableUncaughtExceptionHandler?: boolean; // android only
  ignoreReadPhoneStatePermission?: boolean; // android only
  loadingSpinnerDrawableResName?: string; // android only


  fallbackPhoneNumber?: string;
  preferredLanguage?: string;
  pstnFallbackSensitivity?: number;
  showSingleChannel?: boolean;
  ignoreDarkMode?: boolean;
  autoMinimizeCallWaiting: boolean;
  agentImageWithoutBorderAndRounding: boolean;
  hideMediaAttachmentInChat: boolean;
  cobrowseKey?: string;
  cobrowseApi?: string;
  blockChatTerminationByEndUser?: boolean;
  hideStatusBar?: boolean;
}

interface CustomData {
  [key: string]: {
    label: string;
    value: string | number | Date;
    type: 'string' | 'number' | 'date' | 'url';
  };
}

export interface UJETInterface {
  initialize: (option: InitOption) => void;

  start: (option: StartOption) => void;
  setGlobalOptions: (option: UJETGlobalOptions) => void;
  setGlobalTheme: (option: UJETGlobalTheme) => void;
  setLogLevel: (level: string) => void;

  clearUserData: () => void;
  disconnect: () => Promise<any>;

  getStatus: () => Promise<'none' | 'chat' | 'voip-call' | 'pstn-call'>;

  notifySignPayloadResult: (result: SignPayloadResult) => void;

  // Entender melhor, criar uma spike
  handlePushNotification: (payload: [string: string]) => Promise<boolean>; // true if it's handled by the module
  updatePushToken: (token: string) => void; // ios only
  updateVoipToken: (token: string) => void; // ios only
  minimize: () => Promise<any>; // ios only
}

interface IFontOptions {
  color_reference?: string;
  size?: number;
  family?: string;
  style?: 'bold' | 'italic';
}

interface IBorderOptions {
  width?: number;
  color_reference?: string;
}

interface IButtonOptions {
  background_color_reference?: string;
  corner_radius?: number;
  border?: IBorderOptions;
  font?: IFontOptions;
}

interface IAvatarOptions {
  visible?: boolean;
  size?: number;
  position?: 'left' | 'overlay';
  image_reference?: string;
}

interface IInputOptions {
  cursor_color_reference?: string;
  placeholder_text?: string;
  corner_radius?: string;
  border?: IBorderOptions;
  font?: IFontOptions;
}

interface IIconOptions {
  visible?: boolean;
  image_reference?: string;
}

interface IChatBubbleOptions {
  background_color_reference?: string;
  corner_radius?: number;
  border?: IBorderOptions;
  font?: IFontOptions;
  avatar?: IAvatarOptions;
}

export interface IChatTheme {
  chat: {
    back_button?: {
      visible?: boolean;
      image_reference?: string;
      text_color_reference?: string;
      accessibility_label_reference?: string;
    };
    header?: {
      text_content?: string;
      visible?: boolean;
      show_avatar_icon?: boolean;
      font?: IFontOptions;
      divider?: IBorderOptions;
    };
    end_chat_button?: {
      visible?: boolean;
      font?: IFontOptions;
    };
    timestamp?: {
      font?: IFontOptions;
    };
    system_message?: {
      background_color_reference?: string;
      corner_radius?: number;
      border?: IBorderOptions;
      font?: IFontOptions;
      button?: IButtonOptions;
    };
    agent_message_bubble?: IChatBubbleOptions;
    consumer_message_bubble?: IChatBubbleOptions;
    user_input_bar?: {
      background_color_reference?: string;
      input_field?: IInputOptions;
      top_border?: IBorderOptions;
      menu_action_icon?: IIconOptions;
      send_button?: IIconOptions;
      escalate_icon?: IIconOptions;
    };
    chat_actions_menu?: {
      photo_library_icon?: IIconOptions;
      camera_icon?: IIconOptions;
      cobrowse_icon?: IIconOptions;
    };
    content_card?: {
      background_color_reference?: string;
      corner_radius?: number;
      border?: IBorderOptions;
      font?: IFontOptions;
      title?: {
        font?: IFontOptions;
      };
      subtitle?: {
        font?: IFontOptions;
      };
      body?: {
        font?: IFontOptions;
      };
      image?: {
        height?: number;
      };
      primary_button?: IButtonOptions;
      secondary_button?: IButtonOptions;
    };
    form_card?: {
      background_color_reference?: string;
      corner_radius?: number;
      border?: IBorderOptions;
      font?: IFontOptions;
      title?: {
        font?: IFontOptions;
      };
      subtitle?: {
        font?: IFontOptions;
      };
      image?: {
        height?: number;
      };
      post_session?: {
        background_color_reference?: string;
        border?: IBorderOptions;
      };
    };
  };
}
