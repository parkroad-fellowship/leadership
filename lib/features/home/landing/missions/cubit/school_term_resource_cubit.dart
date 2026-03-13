import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/services/api/school_term_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class SchoolTermResourceCubit extends ResourceCubit<PRFSchoolTerm> {
  SchoolTermResourceCubit({required SchoolTermService schoolTermService})
    : super(service: schoolTermService);

  Future<void> loadActive() {
    return loadAll(
            filters: {'status_key': PRFActiveStatus.active.apiKey},

      orderBy: 'created_at',
      orderDirection: 'desc',
      limit: 200,
    );
  }
}
