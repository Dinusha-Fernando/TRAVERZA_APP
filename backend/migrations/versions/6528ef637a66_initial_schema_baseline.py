"""initial_schema_baseline

Revision ID: 6528ef637a66
Revises: 
Create Date: 2026-10-20 03:23:56.880979

"""
from collections.abc import Sequence

from alembic import op

# revision identifiers, used by Alembic.
revision: str = '6528ef637a66'
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    import app.modules.atlas.models  # noqa
    import app.modules.audit.models  # noqa
    import app.modules.autopilot.models  # noqa
    import app.modules.bookings.models  # noqa
    import app.modules.catalogue.models  # noqa
    import app.modules.community.models  # noqa
    import app.modules.identity.models  # noqa
    import app.modules.messenger.models  # noqa
    import app.modules.notifications.models  # noqa
    import app.modules.packages.models  # noqa
    import app.modules.payments.models  # noqa
    import app.modules.support.models  # noqa
    import app.modules.tripgraph.models  # noqa
    import app.modules.trips.models  # noqa
    from app.core.database import Base

    bind = op.get_bind()
    Base.metadata.create_all(bind)


def downgrade() -> None:
    """Downgrade schema."""
    import app.modules.atlas.models  # noqa
    import app.modules.audit.models  # noqa
    import app.modules.autopilot.models  # noqa
    import app.modules.bookings.models  # noqa
    import app.modules.catalogue.models  # noqa
    import app.modules.community.models  # noqa
    import app.modules.identity.models  # noqa
    import app.modules.messenger.models  # noqa
    import app.modules.notifications.models  # noqa
    import app.modules.packages.models  # noqa
    import app.modules.payments.models  # noqa
    import app.modules.support.models  # noqa
    import app.modules.tripgraph.models  # noqa
    import app.modules.trips.models  # noqa
    from app.core.database import Base

    bind = op.get_bind()
    Base.metadata.drop_all(bind)

