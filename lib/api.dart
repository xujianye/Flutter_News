class Api {
  static final String KEY = '9b96c83a80394a188e5a2d54318227f6';
  static final String HOST = 'http://v.juhe.cn/toutiao/index?key=' + KEY + '&type=';
  static final String Api_Top = HOST + 'top';

  static String getApi(String key) {
    return HOST + key;
  }
}