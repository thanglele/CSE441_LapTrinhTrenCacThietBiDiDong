package com.lele.readnfc

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
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
import org.jmrtd.lds.icao.MRZInfo
import org.jmrtd.lds.iso19794.FaceImageInfo // SỬA LỖI: Đường dẫn import chính xác
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lele.readnfc/nfc"
    private lateinit var channel: MethodChannel
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null

    // AID - Mã định danh ứng dụng cho thẻ CCCD Việt Nam
    private val VIETNAM_AID = byteArrayOf(
        0xA0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x07.toByte(), 0x47.toByte(),
        0x56.toByte(), 0x43.toByte(), 0x44.toByte(), 0x49.toByte(), 0x01.toByte(), 0x00.toByte()
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        
        val flag = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
        pendingIntent = PendingIntent.getActivity(this, 0, intent, flag)
    }

    override fun onResume() {
        super.onResume()
        val filters = arrayOf(IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED))
        val techLists = arrayOf(arrayOf(IsoDep::class.java.name))
        nfcAdapter?.enableForegroundDispatch(this, pendingIntent, filters, techLists)
    }

    override fun onPause() {
        super.onPause()
        nfcAdapter?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (NfcAdapter.ACTION_TECH_DISCOVERED == intent.action || NfcAdapter.ACTION_TAG_DISCOVERED == intent.action) {
            val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
            if (tag != null && tag.techList.contains("android.nfc.tech.IsoDep")) {
                channel.invokeMethod("onNfcDetect", null)
                CoroutineScope(Dispatchers.IO).launch {
                    readNfcTag(tag)
                }
            }
        }
    }

    private suspend fun readNfcTag(tag: Tag) {
        val isoDep = IsoDep.get(tag)
        try {
            isoDep.connect()
            isoDep.timeout = 10000 

            val selectCommand = createSelectAidApdu(VIETNAM_AID)
            val selectResponse = isoDep.transceive(selectCommand)
            
            if (selectResponse.size < 2 || selectResponse[selectResponse.size - 2] != 0x90.toByte() || selectResponse[selectResponse.size - 1] != 0x00.toByte()) {
                 throw Exception("Không thể chọn ứng dụng CCCD. SW: " + selectResponse.toHex())
            }
            Log.d("NFCReader", "Chọn ứng dụng CCCD thành công.")

            val cardService = CardService.getInstance(isoDep)
            val passportService = PassportService(
                cardService,
                PassportService.NORMAL_MAX_TRANCEIVE_LENGTH,
                PassportService.DEFAULT_MAX_BLOCKSIZE,
                false, 
                false
            )
            passportService.open()

            // TODO: Thay thế bằng thông tin thật trên thẻ CCCD của bạn
            val documentNumber = "034204002840"
            val dateOfBirth = "040828"
            val dateOfExpiry = "290828"

            val bacKey = BACKey(documentNumber, dateOfBirth, dateOfExpiry)
            passportService.doBAC(bacKey)
            Log.d("NFCReader", "Xác thực BAC thành công.")

            val dg1InputStream = passportService.getInputStream(PassportService.EF_DG1)
            val dg1File = DG1File(dg1InputStream)
            val mrzInfo: MRZInfo = dg1File.mrzInfo

            val dg2InputStream = passportService.getInputStream(PassportService.EF_DG2)
            val dg2File = DG2File(dg2InputStream)

            val faceInfos = dg2File.faceInfos
            var photoBase64 = ""
            if (faceInfos.isNotEmpty()) {
                val faceImageInfo: FaceImageInfo = faceInfos.first().faceImageInfos.first()
                val imageInputStream: InputStream = faceImageInfo.imageInputStream
                val imageBytes = imageInputStream.readBytes()
                photoBase64 = Base64.encodeToString(imageBytes, Base64.NO_WRAP)
            }

            val cardData = hashMapOf(
                "documentNumber" to mrzInfo.documentNumber,
                "fullName" to "${mrzInfo.secondaryIdentifier.replace("<", " ").trim()} ${mrzInfo.primaryIdentifier.replace("<", " ").trim()}",
                "dateOfBirth" to formatYYMMDD(mrzInfo.dateOfBirth),
                "gender" to mrzInfo.gender.toString(),
                "dateOfExpiry" to formatYYMMDD(mrzInfo.dateOfExpiry),
                "nationality" to mrzInfo.nationality,
                "photo" to photoBase64,
                "personalIdentification" to mrzInfo.optionalData1, 
                "placeOfOrigin" to "", 
                "placeOfResidence" to "",
                "dateOfIssue" to "", 
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
        } finally {
            if (isoDep.isConnected) {
                isoDep.close()
            }
        }
    }

    private fun createSelectAidApdu(aid: ByteArray): ByteArray {
        val command = ByteArray(aid.size + 6)
        command[0] = 0x00 
        command[1] = 0xA4.toByte()
        command[2] = 0x04 
        command[3] = 0x0C
        command[4] = aid.size.toByte()
        System.arraycopy(aid, 0, command, 5, aid.size)
        command[command.size - 1] = 0x00
        return command
    }

    private fun ByteArray.toHex(): String = joinToString(separator = "") { "%02x".format(it) }

    private fun formatYYMMDD(date: String): String {
        if (date.length != 6) return date
        try {
            val year = date.substring(0, 2).toInt()
            val month = date.substring(2, 4)
            val day = date.substring(4, 6)
            val currentYearLastTwoDigits = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) % 100
            val century = if (year > currentYearLastTwoDigits + 10) "19" else "20"
            return "$day/$month/$century$year"
        } catch (e: Exception) {
            return date 
        }
    }
}