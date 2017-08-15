class MessageReceiverValidator< ActiveModel::Validator
  def validate(record)
    if record.circle_id.nil? and record.receiver_id.nil?
      record.errors[:base] << I18n.t("activerecord.errors.models.message.validator.no_receiver_and_no_circle")
    end  
  end
end