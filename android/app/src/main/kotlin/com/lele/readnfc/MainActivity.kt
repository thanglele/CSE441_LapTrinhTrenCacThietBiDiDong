package com.lele.readnfc

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import net.sf.scuba.smartcards.CardService
import org.jmrtd.BACKey
import org.jmrtd.PassportService
import org.jmrtd.lds.icao.DG1File
import org.jmrtd.lds.icao.DG2File
import org.jmrtd.lds.icao.FaceImageInfo
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lele.readnfc/nfc"
    private lateinit var channel: MethodChannel
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        // Tạo PendingIntent để hệ thống có thể khởi chạy lại Activity này khi có thẻ NFC
        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)
    }

    override fun onResume() {
        super.onResume()
        // Ưu tiên bắt sự kiện NFC khi app đang ở foreground
        nfcAdapter?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        // Hủy ưu tiên khi app không ở foreground
        nfcAdapter?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (NfcAdapter.ACTION_TECH_DISCOVERED == intent.action) {
            val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
            if (tag != null && tag.techList.contains("android.nfc.tech.IsoDep")) {
                // Gửi tín hiệu đang đọc thẻ về Flutter
                channel.invokeMethod("onNfcDetect", null)
                // Chạy việc đọc thẻ trên một Coroutine để không block UI Thread
                CoroutineScope(Dispatchers.IO).launch {
                    readNfcTag(tag)
                }
            }
        }
    }

    private suspend fun readNfcTag(tag: Tag) {
        try {
            val isoDep = IsoDep.get(tag)
            isoDep.timeout = 10000 // Tăng thời gian chờ
            val cardService = CardService.getInstance(isoDep)
            val passportService = PassportService(cardService)
            passportService.open()

            // --- QUAN TRỌNG: Xác thực BAC (Basic Access Control) ---
            // TODO: Thay thế bằng thông tin thật trên thẻ CCCD của bạn để thử nghiệm
            // Trong ứng dụng thực tế, người dùng phải nhập thông tin này
            // hoặc quét từ mã QR trên thẻ.
            val documentNumber = "001099001234"  // SỐ CCCD (12 số)
            val dateOfBirth = "990101"        // NGÀY SINH (YYMMDD)
            val dateOfExpiry = "390101"       // NGÀY HẾT HẠN (YYMMDD)

            val bacKey = BACKey(documentNumber, dateOfBirth, dateOfExpiry)
            passportService.doBAC(bacKey)

            // Đọc các Data Group (DG)
            val dg1InputStream = passportService.getInputStream(PassportService.EF_DG1)
            val dg1File = DG1File(dg1InputStream)
            val mrzInfo = dg1File.mrzInfo

            val dg2InputStream = passportService.getInputStream(PassportService.EF_DG2)
            val dg2File = DG2File(dg2InputStream)

            // Lấy ảnh chân dung
            val faceInfos = dg2File.faceInfos
            var photoBase64 = ""
            if (faceInfos.isNotEmpty()) {
                val faceImageInfo = faceInfos.first().faceImageInfos.first()
                val imageInputStream: InputStream = faceImageInfo.imageInputStream
                val imageBytes = imageInputStream.readBytes()
                photoBase64 = Base64.encodeToString(imageBytes, Base64.NO_WRAP)
            }

            // Tạo map để gửi về Flutter
            val cardData = hashMapOf(
                "documentNumber" to mrzInfo.documentNumber,
                "fullName" to "${mrzInfo.secondaryIdentifier.replace("<", " ").trim()} ${mrzInfo.primaryIdentifier.replace("<", " ").trim()}",
                "dateOfBirth" to formatYYMMDD(mrzInfo.dateOfBirth),
                "gender" to mrzInfo.gender.toString(),
                "dateOfExpiry" to formatYYMMDD(mrzInfo.dateOfExpiry),
                "nationality" to mrzInfo.nationality,
                "photo" to photoBase64,
                // Các trường này cần phân tích sâu hơn từ chuỗi MRZ hoặc các DG khác
                "personalIdentification" to mrzInfo.personalNumber,
                "placeOfOrigin" to "", // Cần đọc từ DG13 hoặc phân tích
                "placeOfResidence" to "", // Cần đọc từ DG13 hoặc phân tích
                "dateOfIssue" to "", // Cần đọc từ DG11 hoặc phân tích
                "ethnicity" to "",
                "religion" to ""
            )

            withContext(Dispatchers.Main) {
                channel.invokeMethod("onNfcDataReceived", cardData)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e("NFCReader", "Error reading NFC tag", e)
            withContext(Dispatchers.Main) {
                channel.invokeMethod("onNfcError", "Lỗi: ${e.message}")
            }
        }
    }

    private fun formatYYMMDD(date: String): String {
        if (date.length != 6) return date
        val year = date.substring(0, 2)
        val month = date.substring(2, 4)
        val day = date.substring(4, 6)
        // Heuristic to determine century
        val currentYearLastTwoDigits = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) % 100
        val century = if (year.toInt() > currentYearLastTwoDigits) "19" else "20"
        return "$day/$month/$century$year"
    }
}
