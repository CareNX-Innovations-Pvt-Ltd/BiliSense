class LCJaundiceDecoder {
  const LCJaundiceDecoder();

  double decodeData(List<int> data) {
    double jaundiceValue = 0.0;
    if (data.length >= 8 &&
        data[0] == 0x55 &&
        data[1] == 0xAA &&
        data[4] == 0xA6) {
      int jaundiceData = (data[6] << 8) | (data[5] & 0xFF);
      jaundiceValue = jaundiceData / 10.0;
    }
    return jaundiceValue;
  }
}
