import 'package:intl/intl.dart';

class CoinTool {
  static String format(int coins) => NumberFormat('#,###').format(coins);
  static double toUsd(int coins, {int coinCount = 1000000, double rate = 1}) =>
      coins / coinCount * rate;
  static bool canWithdraw(int balance, int required) => balance >= required;
}
