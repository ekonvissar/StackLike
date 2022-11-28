module Authentication
    extend ActiveSupport::Concern
   
    included do 
        private 
        
        def current_user
            if session[:user_id].present?
                @current_user ||= User.find_by(id: session[:user_id]).decorate
            elsif cookies.encrypted[:user_id].present?
                user = User.find_by(cookies.encrypted[:user_id])
                if user&.remember_token_authenticated?(cookies.encrypted[:remeber_token])
                    sign_in user
                    @current_user ||= user.decorate
                end
            end
        end
    
        def user_signed_in?
            current_user.present?
        end

        def sign_in(user)
            session[:user_id] = user.id
        end

        def sign_out
            forget current_user
            session.delete  :user_id
            @current_user = nil
        end

        def require_no_authenticate
            return unless user_signed_in?
            flash[:danger] = 'You are already registred!'
            redirect_to root_path                
        end

        def require_authenticate
            return if user_signed_in?
            flash[:danger] = 'You are not registred yet!'
            redirect_to root_path             
        end    

        def remember(user)
            user.remember_me
            cookies.encrypted.permanent[:remeber_token] = user.remember_token
            cookies.encrypted.permanent[:user] = user.id
        end
        
        def forget(user)
            user.forget_me
            cookies.delete :user_id
            cookies.delete :remember_token
        end


        helper_method :current_user, :user_signed_in?
    end
    
end