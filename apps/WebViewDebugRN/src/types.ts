import type {WebViewConfig} from './screens/ConfigScreen';

export type RootStackParamList = {
  Config: undefined;
  Preview: {config: WebViewConfig};
};
