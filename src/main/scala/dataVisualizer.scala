import org.apache.log4j.{Level, LogManager}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.sql.SparkSession


object dataVisualizer {

  def main(args: Array[String]): Unit = {
    LogManager.getLogger("org").setLevel(Level.OFF)
    LogManager.getLogger("akka").setLevel(Level.OFF)

    val spark = SparkSession
      .builder()
      .appName("Spark SQL basic example")
      .master("local")
      .getOrCreate()

    import spark.implicits._
    val df = spark.read.csv("data/HIGGS.csv")

    val newDF = df.sample(false, 0.0002)

    newDF.coalesce(1).write.option("header",true).csv("data/HIGGSsample")

    spark.close()

    val conf = new SparkConf().setAppName("dataProcessing").setMaster("local[*]")
    val sc = new SparkContext(conf)

    import org.apache.hadoop.fs._
    import org.apache.hadoop.fs.FileSystem
    val fs = FileSystem.get(sc.hadoopConfiguration)
    val file = fs.globStatus(new Path("data/HIGGSsample/part*"))(0).getPath().getName()

    fs.rename(new Path("data/HIGGSsample/" + file), new Path("data/HIGGSsample.csv"))
    fs.delete(new Path("mydata.csv-temp"), true)
  }
}