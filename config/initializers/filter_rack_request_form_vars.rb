# Without this monkeypatch, exception_notifier will send the rack.request.form_vars
# in an exception email without filtering, which can include password parameters
#
# https://github.com/smartinez87/exception_notification/issues/99
module ActionDispatch
  module Http
    module FilterParameters
      protected

      def env_filter
        parameter_filter_for(Array(@env["action_dispatch.parameter_filter"]) + [/RAW_POST_DATA/, "rack.request.form_vars"])
      end
    end
  end
end
