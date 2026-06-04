package vn.chuongpl.badbook.common.exception;

import lombok.Getter;
import vn.chuongpl.badbook.common.enums.ErrorCode;

@Getter
public class AppException extends RuntimeException {

    private ErrorCode errorCode;

    public AppException(ErrorCode errorCode){
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

}
