object SleepSort {

  def main(args: Array[String]): Unit = {
    val nums = args.map(_.toInt)
    sort(nums)
    Thread.sleep(nums.max * 21) // Keep the JVM alive for the example
  }

  def sort(nums: Seq[Int]): Unit =
    nums.foreach(i => new Thread {
      override def run() {
        Thread.sleep(i * 20) // just `i` is unpredictable with small numbers
        print(s"$i ")
      }
    }.start())

}
