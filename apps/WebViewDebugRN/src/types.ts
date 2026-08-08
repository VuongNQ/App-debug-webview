import type { WebViewConfig } from './config/webViewConfig';

export type RootStackParamList = {
  Config: undefined;
  Preview: { config: WebViewConfig };
};
