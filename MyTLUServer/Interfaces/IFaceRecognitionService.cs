namespace MyTLUServer.Application.Interfaces
{
    public interface IFaceRecognitionService
    {
        /// <summary>
        /// So sánh 2 yếu tố (có thể là embedding vs base64, hoặc 2 embedding)
        /// </summary>
        Task<bool> VerifyFaceAsync(string savedEmbedding, string liveSelfieBase64);

        /// <summary>
        /// Tạo embedding SƠ KHAI (từ ảnh 2D hoặc 3D)
        /// </summary>
        Task<string> GenerateEmbeddingAsync(string dataBase64);

        /// <summary>
        /// TINH CHỈNH: Lấy vector 2D cũ và dữ liệu 3D mới để tạo ra 1 vector CHUẨN
        /// </summary>
        Task<string> RefineEmbeddingAsync(string base2DEmbedding, string data3DBase64);
    }
}